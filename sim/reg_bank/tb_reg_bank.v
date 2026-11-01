`timescale 1ns/1ps
module tb_reg_bank;
    reg clk=0; always #4 clk=~clk;
    reg [3:0] data_in=0;
    reg [1:0] address=0,sel_a=0,sel_b=0;
    reg write_enable=0;
    wire [3:0] qa,qb;
    reg [3:0] model[0:3];
    integer i,j,k,v,checks=0;
    reg_bank dut(clk,data_in,address,write_enable,sel_a,sel_b,qa,qb);
    task verify_reads;
        begin
            for(j=0;j<4;j=j+1) for(k=0;k<4;k=k+1) begin
                @(negedge clk); sel_a=j;sel_b=k; #1;
                if(qa!==model[j] || qb!==model[k]) $fatal(1,"Reg bank lectura/aislamiento");
                checks=checks+1;
            end
        end
    endtask
    initial begin
        for(i=0;i<4;i=i+1) model[i]=0;
        verify_reads;
        for(i=0;i<4;i=i+1) for(v=0;v<16;v=v+1) begin
            @(negedge clk); address=i;data_in=v;write_enable=1;
            // No debe cambiar antes del flanco positivo.
            #1; if(qa!==model[sel_a] || qb!==model[sel_b]) $fatal(1,"Escritura asincrona");
            @(negedge clk); write_enable=0;model[i]=v;
            verify_reads;
            data_in=~v; repeat(2) @(negedge clk);
            if(qa!==model[sel_a] || qb!==model[sel_b]) $fatal(1,"Escritura sin enable");
        end
        $display("PASS REG_BANK: 64 escrituras, %0d pares de lectura; retencion y aislamiento",checks);
        $finish;
    end
    initial begin
        $dumpfile("reg_bank.vcd");
        $dumpvars(0,tb_reg_bank);
    end
endmodule
