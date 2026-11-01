`timescale 1ns/1ps
`default_nettype none
module edge_detector(input wire clk, sig_in, output wire out);
    reg sig_prev = 0;
    always @(posedge clk) sig_prev <= sig_in;
    assign out = sig_in & ~sig_prev;
endmodule
`default_nettype wire
