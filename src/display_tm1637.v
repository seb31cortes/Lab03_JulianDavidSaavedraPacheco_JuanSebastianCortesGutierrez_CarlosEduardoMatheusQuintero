`timescale 1ns/1ps
`default_nettype none
module display_tm1637 #(parameter integer CLK_HZ = 125_000_000,
    parameter integer BIT_HZ = 100_000)(input wire clk,
    input wire signed [5:0] result, output wire tm_clk, inout wire tm_dio,
    output wire ack_err, input wire binary_mode);
    wire [31:0] segments;
    display_formatter u_fmt(.result(result), .segments(segments), .binary_mode(binary_mode));
    tm1637_driver #(.CLK_HZ(CLK_HZ), .BIT_HZ(BIT_HZ)) u_driver(
        .clk(clk), .segments(segments), .tm_clk(tm_clk),
        .tm_dio(tm_dio), .ack_err(ack_err));
endmodule
`default_nettype wire
