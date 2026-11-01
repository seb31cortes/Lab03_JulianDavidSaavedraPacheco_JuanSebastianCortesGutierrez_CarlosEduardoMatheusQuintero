`timescale 1ns/1ps
`default_nettype none
module address(input wire clk, btn0_rising_edge, output wire [1:0] address);
    reg [1:0] address_reg = 0;
    always @(posedge clk)
        if (btn0_rising_edge) address_reg <= address_reg + 2'd1;
    assign address = address_reg;
endmodule
`default_nettype wire
