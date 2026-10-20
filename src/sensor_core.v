`timescale 1ns / 1ps
module sensor_core #(
    parameter CLKS_PER_BIT  = 104,
    parameter THRESHOLD     = 16'h8000,
    parameter FILTER_CYCLES = 120_000    
)(
    input  wire        clk,
    input  wire [15:0] adc_data,
    input  wire        ready,             
    output reg         tx = 1'b1
);

    // 1) komparator
    reg is_above = 0;
    always @(posedge clk) begin
        if (ready)
            is_above <= (adc_data > THRESHOLD);
    end

    // 2) filtr czasowy + 3) detektor zbocza
    reg [31:0] timer = 0;
    reg trigger_flag = 0;
    reg prev_trigger = 0;
    wire trigger_uart = trigger_flag & ~prev_trigger;

    always @(posedge clk) begin
        if (is_above) begin
            if (timer < FILTER_CYCLES) begin
                timer <= timer + 1;
                trigger_flag <= 1'b0;
            end else begin
                trigger_flag <= 1'b1;
            end
        end else begin
            timer <= 0;
            trigger_flag <= 1'b0;
        end
        prev_trigger <= trigger_flag;
    end

    // 4) automat UART (8N1)
    reg [2:0]  state = 0;
    reg [15:0] clock_count = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  tx_data = 8'h43;

    always @(posedge clk) begin
        case (state)
            3'd0: begin
                tx <= 1'b1;
                clock_count <= 0;
                bit_index <= 0;
                if (trigger_uart) state <= 3'd1;
            end
            3'd1: begin                   // bit startu
                tx <= 1'b0;
                if (clock_count < CLKS_PER_BIT - 1) clock_count <= clock_count + 1;
                else begin clock_count <= 0; state <= 3'd2; end
            end
            3'd2: begin                   // 8 bitów danych, LSB pierwszy
                tx <= tx_data[bit_index];
                if (clock_count < CLKS_PER_BIT - 1) clock_count <= clock_count + 1;
                else begin
                    clock_count <= 0;
                    if (bit_index < 7) bit_index <= bit_index + 1;
                    else begin bit_index <= 0; state <= 3'd3; end
                end
            end
            3'd3: begin                   // bit stopu
                tx <= 1'b1;
                if (clock_count < CLKS_PER_BIT - 1) clock_count <= clock_count + 1;
                else begin clock_count <= 0; state <= 3'd0; end
            end
            default: state <= 3'd0;
        endcase
    end
endmodule