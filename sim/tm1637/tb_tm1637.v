`timescale 1ns/1ps
module tb_tm1637;
    // 4 MHz reales en esta simulacion, serial 100 kHz (DIV=10).
    reg clk=0;always #125 clk=~clk;
    reg [31:0] segments=32'h063f063f;
    reg ack=1;
    wire tm_clk,tm_dio,ack_err;
    reg [31:0] received=0,frames=0;
    tm1637_driver #(.CLK_HZ(4_000_000)) dut(clk,segments,tm_clk,tm_dio,ack_err);
    // Recepcion del bus y ACK del display, integrados en este testbench.
    reg tm_rx_ack_low=0,tm_rx_active=0;
    reg [7:0] tm_rx_byte_value=0;
    reg [7:0] tm_rx_bytes[0:7];
    integer tm_rx_bits=0,tm_rx_count=0;
    reg tm_rx_got_mode=0,tm_rx_got_data=0;
    assign tm_dio=tm_rx_ack_low ? 1'b0 : 1'bz;
    pullup(tm_dio);
    always @(negedge tm_dio) if(tm_clk===1'b1) begin
        if(tm_rx_active) $fatal(1,"START inesperado dentro de transaccion");
        tm_rx_active=1;tm_rx_bits=0;tm_rx_count=0;tm_rx_byte_value=0;
    end
    always @(posedge tm_clk) if(tm_rx_active) begin
        if(tm_dio!==1'b0 && tm_dio!==1'b1) $fatal(1,"DIO indefinido/contencion");
        if(tm_rx_bits<8) tm_rx_byte_value[tm_rx_bits]=tm_dio;
        else if(tm_rx_bits==8) begin
            if(tm_rx_count>=7) $fatal(1,"Demasiados tm_rx_bytes");
            tm_rx_bytes[tm_rx_count]=tm_rx_byte_value;tm_rx_count=tm_rx_count+1;
            if(tm_dio!==!(ack)) $fatal(1,"Slot ACK incorrecto");
        end else $fatal(1,"Relojes extra");
        tm_rx_bits=tm_rx_bits+1;
    end
    always @(negedge tm_clk) if(tm_rx_active) begin
        if(tm_rx_bits==8) tm_rx_ack_low=(ack);
        else if(tm_rx_bits==9) begin tm_rx_ack_low=0;tm_rx_bits=0;tm_rx_byte_value=0;end
    end
    always @(posedge tm_dio) if(tm_clk===1'b1 && tm_rx_active) begin
        tm_rx_active=0;
        case(tm_rx_bytes[0])
            8'h40: begin
                if(tm_rx_count!=1) $fatal(1,"Longitud comando modo");
                tm_rx_got_mode=1;
            end
            8'hc0: begin
                if(tm_rx_count!=5 || !tm_rx_got_mode) $fatal(1,"Direccion/datos/orden incorrectos");
                received={tm_rx_bytes[1],tm_rx_bytes[2],tm_rx_bytes[3],tm_rx_bytes[4]};
                tm_rx_got_data=1;
            end
            8'h8f: begin
                if(tm_rx_count!=1 || !tm_rx_got_mode || !tm_rx_got_data) $fatal(1,"Control brillo/orden");
                frames=frames+1;tm_rx_got_mode=0;tm_rx_got_data=0;
            end
            default: $fatal(1,"Comando TM1637 inesperado: %h",tm_rx_bytes[0]);
        endcase
    end
    task next_frame;
        reg [31:0] n;
        begin n=frames;wait(frames>n);#1000;end
    endtask
    initial begin
        $dumpfile("tm1637.vcd");
        $dumpvars(0,segments,ack,tm_clk,tm_dio,ack_err,received,frames);
        next_frame;
        if(received!==segments || ack_err!==0) $fatal(1,"Trama inicial o ACK");
        // Cambiar datos DURANTE la trama: los cuatro bytes siguen siendo coherentes.
        wait(dut.state==2 && dut.idx==2);segments=32'h3f063f06;
        next_frame;
        if(received!==32'h063f063f) $fatal(1,"Trama mezclada");
        next_frame;
        if(received!==segments) $fatal(1,"Nueva trama no actualizada");
        // Un NACK temprano no debe desaparecer con los ACK posteriores.
        wait(dut.state==1 && dut.idx==0);ack=0;
        wait(dut.state==4 && dut.idx==0);ack=1;
        next_frame;
        if(ack_err!==1) $fatal(1,"NACK temprano no retenido en trama");
        next_frame;
        if(ack_err!==0) $fatal(1,"Recuperacion ACK");
        ack=0;next_frame;
        if(ack_err!==1) $fatal(1,"Display ausente no detectado");
        ack=1;next_frame;
        if(ack_err!==0 || received!==segments) $fatal(1,"Recuperacion final");
        $display("PASS TM1637: %0d tramas, comandos, LSB, ACK/NACK, coherencia y recuperacion",frames);
        $finish;
    end
    initial begin #20_000_000;$fatal(1,"Timeout TM1637");end
endmodule
