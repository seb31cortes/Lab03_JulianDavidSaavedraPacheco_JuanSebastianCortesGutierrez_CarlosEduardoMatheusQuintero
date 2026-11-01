`timescale 1ns/1ps
`default_nettype none
module result_register(input wire clk, execute, input wire signed [5:0] alu_result,
    output reg signed [5:0] result_q = 0,
    input wire binary_mode, output reg binary_q = 0);
    always @(posedge clk)
        if (execute) begin
            result_q <= alu_result;
            binary_q <= binary_mode;
        end
endmodule
`default_nettype wire
