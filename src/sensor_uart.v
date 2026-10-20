`timescale 1ns / 1ps
module sensor_uart (
    input  wire clk,
    input  wire vauxp4,
    input  wire vauxn4,
    output wire tx
);
    wire        enable, ready;
    wire [15:0] adc_data;
 
    xadc_wiz_0 XADC_inst (
        .daddr_in(7'h14), .den_in(enable), .di_in(16'h0000), .dwe_in(1'b0),
        .do_out(adc_data), .drdy_out(ready), .dclk_in(clk), .reset_in(1'b0),
        .vauxp4(vauxp4), .vauxn4(vauxn4),
        .eoc_out(enable), .channel_out(), .eos_out(), .alarm_out(), .busy_out()
    );
 
    sensor_core core_inst (
        .clk(clk), .adc_data(adc_data), .ready(ready), .tx(tx)
    );
endmodule