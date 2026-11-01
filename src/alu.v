`timescale 1ns/1ps
`default_nettype none
// ALU combinacional. Operandos sin signo 0..15; resultado con signo -15..30; sin habilitacion ni memoria.
module alu(input wire [3:0] a, b, input wire [1:0] sel,
           output wire signed [5:0] out);
    // Una asignacion continua tambien evalua entradas inicialmente constantes.
    function signed [5:0] calculate;
        input [3:0] operand_a, operand_b;
        input [1:0] operation;
        begin
        case (operation)
            2'b00: calculate = $signed({2'b00,operand_a}) + $signed({2'b00,operand_b});
            2'b01: calculate = $signed({2'b00,operand_a}) - $signed({2'b00,operand_b});
            2'b10: calculate = operand_a & operand_b;
            2'b11: calculate = operand_a | operand_b;
            default: calculate = 6'sd0;
        endcase
        end
    endfunction
    assign out = calculate(a,b,sel);
endmodule
`default_nettype wire
