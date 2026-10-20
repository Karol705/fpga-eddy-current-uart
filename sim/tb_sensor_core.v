`timescale 1ns / 1ps
module tb_sensor_core;

    parameter FILE           = "C:/Users/baran/OneDrive/Pulpit/adc.txt";
    parameter SAMPLE_CLKS    = 1000;    
    parameter CLKS_PER_BIT   = 104;

    reg         clk = 0;
    reg  [15:0] adc_data = 16'h0000;
    reg         ready = 0;
    wire        tx;

    sensor_core #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut (
        .clk(clk), .adc_data(adc_data), .ready(ready), .tx(tx)
    );

    always #41.667 clk = ~clk;            // 12 MHz

    // --- wczytywanie pliku i podawanie próbek ---
    integer fd, rc, n = 0;
    reg [15:0] val;
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, tb_sensor_core);
        fd = $fopen(FILE, "r");
        if (fd == 0) begin $display("BLAD: nie mozna otworzyc %0s", FILE); $finish; end
        while (!$feof(fd)) begin
            rc = $fscanf(fd, "%h\n", val);
            if (rc == 1) begin
                @(posedge clk);
                adc_data <= val;
                ready    <= 1'b1;
                @(posedge clk);
                ready    <= 1'b0;
                repeat (SAMPLE_CLKS - 2) @(posedge clk);
                n = n + 1;
            end
        end
        $fclose(fd);
        repeat (2000) @(posedge clk);
        $display("Koniec: wczytano %0d probek, t = %0t ns", n, $time);
        $finish;
    end

    // --- odbiornik UART  ---
    integer i;
    reg [7:0] rx_byte;
    initial begin
        forever begin
            @(negedge tx);                              // bit startu
            repeat (CLKS_PER_BIT + CLKS_PER_BIT/2) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin
                rx_byte[i] = tx;
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
            $display("[%0t ns] RPi odebralo bajt: 0x%02h  ('%c')", $time, rx_byte, rx_byte);
        end
    end
endmodule