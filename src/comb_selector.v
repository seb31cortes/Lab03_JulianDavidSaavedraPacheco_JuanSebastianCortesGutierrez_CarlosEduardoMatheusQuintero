`timescale 1ns/1ps
`default_nettype none
// Recorre los 16 pares ORDENADOS: (R0,R0), (R0,R1), ... (R3,R3).
module comb_selector(input wire clk, btn2_rising_edge,
    output wire [1:0] sel_a, sel_b);
    reg [3:0] comb_reg = 0;
    always @(posedge clk)
        if (btn2_rising_edge) comb_reg <= comb_reg + 4'd1;
    assign sel_a = comb_reg[3:2];
    assign sel_b = comb_reg[1:0];
endmodule
`default_nettype wire
