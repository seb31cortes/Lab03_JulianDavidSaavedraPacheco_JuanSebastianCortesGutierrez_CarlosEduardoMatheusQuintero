`timescale 1ns/1ps
module tb_controls;
    reg clk=0;always #4 clk=~clk;
    reg next_addr=0,next_pair=0,execute=0;
    reg signed [5:0] alu_result=0;
    reg binary_mode=0; wire binary_q;
    wire [1:0] addr,a,b;
    wire [3:0] led;
    wire signed [5:0] result_q;
    wire [2:0] rgb;
    integer i;
    reg [2:0] exp_rgb;
    address u1(clk,next_addr,addr);
    comb_selector u2(clk,next_pair,a,b);
    result_register u3(clk,execute,alu_result,result_q,binary_mode,binary_q);
    indicators u4(addr,a,b,led,rgb);
    initial begin
        #1;
        if(addr!==0 || {a,b}!==0 || result_q!==0) $fatal(1,"Arranque controles");
        for(i=0;i<32;i=i+1) begin
            case(i%4) 0:exp_rgb=4;1:exp_rgb=2;2:exp_rgb=1;3:exp_rgb=7;endcase
            if(addr !== (i%4) || {a,b} !== (i%16)) $fatal(1,"Secuencia selectores");
            if(led!==(i%16) || rgb!==exp_rgb) $fatal(1,"Indicadores");
            @(negedge clk);alu_result=i-16;binary_mode=i%2;execute=1;
            @(negedge clk);execute=0;
            if(result_q!==(i-16) || binary_q!==(i%2)) $fatal(1,"Captura resultado");
            binary_mode=~binary_mode;alu_result=~i;repeat(3) @(negedge clk);
            if(result_q!==(i-16) || binary_q!==(i%2)) $fatal(1,"Retencion resultado");
            next_addr=1;next_pair=1;
            @(negedge clk);next_addr=0;next_pair=0;
            repeat(2) @(negedge clk);
        end
        $display("PASS CONTROLS: direccion, 16 pares ordenados x2, RGB, LEDs y resultado");$finish;
    end
    initial begin
        $dumpfile("controls.vcd");
        $dumpvars(0,tb_controls);
    end
endmodule
