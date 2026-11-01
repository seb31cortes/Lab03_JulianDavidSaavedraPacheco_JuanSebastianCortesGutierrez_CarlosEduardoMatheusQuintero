`timescale 1ns/1ps
module tb_display_formatter;
 reg signed [5:0] value;
 wire [31:0] segments;
 reg [31:0] expected[0:63];
 integer i,j;
 reg binary_mode=0;
 reg [31:0] bits_expected;
 display_formatter dut(value,segments,binary_mode);
 initial begin
 expected[0]=32'h403f4f5b;
 expected[1]=32'h403f4f06;
 expected[2]=32'h403f4f3f;
 expected[3]=32'h403f5b6f;
 expected[4]=32'h403f5b7f;
 expected[5]=32'h403f5b07;
 expected[6]=32'h403f5b7d;
 expected[7]=32'h403f5b6d;
 expected[8]=32'h403f5b66;
 expected[9]=32'h403f5b4f;
 expected[10]=32'h403f5b5b;
 expected[11]=32'h403f5b06;
 expected[12]=32'h403f5b3f;
 expected[13]=32'h403f066f;
 expected[14]=32'h403f067f;
 expected[15]=32'h403f0607;
 expected[16]=32'h403f067d;
 expected[17]=32'h403f066d;
 expected[18]=32'h403f0666;
 expected[19]=32'h403f064f;
 expected[20]=32'h403f065b;
 expected[21]=32'h403f0606;
 expected[22]=32'h403f063f;
 expected[23]=32'h403f3f6f;
 expected[24]=32'h403f3f7f;
 expected[25]=32'h403f3f07;
 expected[26]=32'h403f3f7d;
 expected[27]=32'h403f3f6d;
 expected[28]=32'h403f3f66;
 expected[29]=32'h403f3f4f;
 expected[30]=32'h403f3f5b;
 expected[31]=32'h403f3f06;
 expected[32]=32'h3f3f3f3f;
 expected[33]=32'h3f3f3f06;
 expected[34]=32'h3f3f3f5b;
 expected[35]=32'h3f3f3f4f;
 expected[36]=32'h3f3f3f66;
 expected[37]=32'h3f3f3f6d;
 expected[38]=32'h3f3f3f7d;
 expected[39]=32'h3f3f3f07;
 expected[40]=32'h3f3f3f7f;
 expected[41]=32'h3f3f3f6f;
 expected[42]=32'h3f3f063f;
 expected[43]=32'h3f3f0606;
 expected[44]=32'h3f3f065b;
 expected[45]=32'h3f3f064f;
 expected[46]=32'h3f3f0666;
 expected[47]=32'h3f3f066d;
 expected[48]=32'h3f3f067d;
 expected[49]=32'h3f3f0607;
 expected[50]=32'h3f3f067f;
 expected[51]=32'h3f3f066f;
 expected[52]=32'h3f3f5b3f;
 expected[53]=32'h3f3f5b06;
 expected[54]=32'h3f3f5b5b;
 expected[55]=32'h3f3f5b4f;
 expected[56]=32'h3f3f5b66;
 expected[57]=32'h3f3f5b6d;
 expected[58]=32'h3f3f5b7d;
 expected[59]=32'h3f3f5b07;
 expected[60]=32'h3f3f5b7f;
 expected[61]=32'h3f3f5b6f;
 expected[62]=32'h3f3f4f3f;
 expected[63]=32'h3f3f4f06;
 for(i=-32;i<32;i=i+1) begin
 value=i; #1;
 if(segments!==expected[i+32]) $fatal(1,"Decimal con signo incorrecto: %0d",i);
 end
 binary_mode=1;
 for(i=0;i<16;i=i+1) begin
 value=i;
 for(j=0;j<4;j=j+1) bits_expected[j*8+:8]=((i>>j)&1)?8'h06:8'h3f;
 #1;if(segments!==bits_expected) $fatal(1,"Binario incorrecto %0d",i);
 end
 $display("PASS FORMATTER: 64 valores decimales con signo y 16 patrones binarios"); $finish;
 end
    initial begin
        $dumpfile("display_formatter.vcd");
        $dumpvars(0,tb_display_formatter);
    end
endmodule
