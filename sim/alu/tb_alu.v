`timescale 1ns/1ps
module tb_alu;
    reg [3:0] a=0, b=0;
    reg [1:0] sel=0;
    wire signed [5:0] out;
    reg signed [5:0] expected;
    integer i,j,k,checks=0;
    alu dut(a,b,sel,out);
    initial begin
        $dumpfile("alu.vcd"); $dumpvars(0,tb_alu);
        #1; if(out!==0) $fatal(1,"ALU desconocida con entradas iniciales constantes");
        for(k=0;k<4;k=k+1) for(i=0;i<16;i=i+1) for(j=0;j<16;j=j+1) begin
            a=i; b=j; sel=k;
            case(k)
                0: expected=i+j;
                1: expected=i-j;
                2: expected=i&j;
                3: expected=i|j;
            endcase
            #10;
            if(out !== expected) $fatal(1,"ALU op=%0d a=%0d b=%0d",k,i,j);
            checks=checks+1;
        end
        $display("PASS ALU: %0d casos exhaustivos (4 x 16 x 16)",checks); $finish;
    end
endmodule
