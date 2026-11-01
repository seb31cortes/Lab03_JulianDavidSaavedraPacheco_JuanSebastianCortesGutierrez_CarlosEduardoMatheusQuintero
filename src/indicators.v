`timescale 1ns/1ps
`default_nettype none
module indicators(input wire [1:0] wr_addr, sel_a, sel_b,
    output wire [3:0] led, output wire [2:0] rgb);
    // LED3:LED2 = indice A; LED1:LED0 = indice B.
    assign led = {sel_a, sel_b};
    // R0 rojo, R1 verde, R2 azul, R3 blanco.
    assign rgb = wr_addr == 0 ? 3'b100 : wr_addr == 1 ? 3'b010 :
                 wr_addr == 2 ? 3'b001 : 3'b111;
endmodule
`default_nettype wire
