`timescale 1ns/1ps
module tb_debouncer;
    parameter integer N=1_250_000;
    reg clk=0;always #4 clk=~clk;
    reg btn=0;
    wire stable,pulse;
    integer pulses=0;
    debouncer #(.STABLE_CYCLES(N)) dut(clk,btn,stable);
    edge_detector edge_dut(clk,stable,pulse);
    always @(posedge clk) if(pulse) pulses=pulses+1;
    task cycles(input integer n);
        repeat(n) @(negedge clk);
    endtask
    initial begin
        cycles(5);
        if(stable!==0 || pulse!==0) $fatal(1,"Arranque desconocido");
        if(N>1) begin
            btn=1;cycles(N-1);btn=0;cycles(N+4);
            if(pulses!=0) $fatal(1,"Acepto rebote corto");
        end
        btn=1; cycles(N+2);
        if(stable!==1 || pulses!=0) $fatal(1,"Umbral incorrecto N=%0d",N);
        cycles(1);
        if(pulses!=1) $fatal(1,"Pulso ausente");
        cycles(N+5);
        if(pulses!=1) $fatal(1,"Repeticion durante presion");
        if(N>1) begin
            btn=0;cycles(N-1);btn=1;cycles(N+4);
            if(pulses!=1 || stable!==1) $fatal(1,"Rebote de liberacion rearma");
        end
        btn=0;cycles(N+4);
        if(stable!==0 || pulses!=1) $fatal(1,"Liberacion");
        btn=1;cycles(N+4);
        if(pulses!=2) $fatal(1,"Segunda pulsacion");
        $display("PASS DEBOUNCER: N=%0d, umbral, rebotes, mantener y rearmar",N);$finish;
    end
    initial begin
        $dumpfile("debouncer_real.vcd");
        $dumpvars(0,btn,stable,pulse,pulses);
    end
endmodule
