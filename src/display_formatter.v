`timescale 1ns/1ps
`default_nettype none
// Decimal con signo: positivos 0000..0031, negativos -001..-032.
module display_formatter(input wire signed [5:0] result, output wire [31:0] segments, input wire binary_mode);
    function [7:0] digit(input [3:0] n);
        case(n)
            0:digit=8'h3f; 1:digit=8'h06; 2:digit=8'h5b;
            3:digit=8'h4f; 4:digit=8'h66; 5:digit=8'h6d;
            6:digit=8'h7d; 7:digit=8'h07; 8:digit=8'h7f;
            9:digit=8'h6f; default:digit=8'h00;
        endcase
    endfunction
    wire negative = result[5];
    wire [5:0] magnitude = negative ? (~result + 6'd1) : result;
    wire [3:0] tens = magnitude >= 30 ? 3 : magnitude >= 20 ? 2 : magnitude >= 10 ? 1 : 0;
    wire [3:0] units = magnitude - tens * 6'd10;
    wire [31:0] decimal_segments = {negative ? 8'h40 : 8'h3f,8'h3f,digit(tens),digit(units)};
    assign segments = binary_mode ? {result[3] ? 8'h06 : 8'h3f,
        result[2] ? 8'h06 : 8'h3f, result[1] ? 8'h06 : 8'h3f,
        result[0] ? 8'h06 : 8'h3f} : decimal_segments;
endmodule
`default_nettype wire
