`timescale 1ns/1ps
`default_nettype none
module sync_inputs #(parameter integer WIDTH = 4)(input wire clk,
    input wire [WIDTH-1:0] async_in, output wire [WIDTH-1:0] synced);
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    reg [WIDTH-1:0] meta = 0, stage2 = 0;
    always @(posedge clk) begin
        meta <= async_in;
        stage2 <= meta;
    end
    assign synced = stage2;
endmodule
`default_nettype wire
