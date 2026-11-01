`timescale 1ns/1ps
module tb_top;
    reg clk=0;always #125 clk=~clk;
    reg [3:0] sw=0,btn=0;
    reg [1:0] sw_sel=0;
    wire [3:0] led;
    wire rgb_r,rgb_g,rgb_b,tm_clk,tm_dio;
    reg [31:0] received=0,frames=0;
    reg [7:0] stage=0;
    reg [3:0] model_regs[0:3];
    reg signed [5:0] expected=0,held=0;
    integer i,k,checks=0;
    reg held_binary=0;
    top #(.CLK_HZ(4_000_000),.DEBOUNCE_CYCLES(4)) dut(
        clk,sw,btn,sw_sel,led,rgb_r,rgb_g,rgb_b,tm_clk,tm_dio);
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
            if(tm_dio!==!(1'b1)) $fatal(1,"Slot ACK incorrecto");
        end else $fatal(1,"Relojes extra");
        tm_rx_bits=tm_rx_bits+1;
    end
    always @(negedge tm_clk) if(tm_rx_active) begin
        if(tm_rx_bits==8) tm_rx_ack_low=(1'b1);
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
    function signed [5:0] reference_alu(input integer a,b,op);
        case(op)
            0:reference_alu=a+b;
            1:reference_alu=a-b;
            2:reference_alu=a&b;
            3:reference_alu=a|b;
        endcase
    endfunction
    function [31:0] decimal_segments(input signed [5:0] r);
        case(r)
            -15:decimal_segments=32'h403f066d;
            -14:decimal_segments=32'h403f0666;
            -13:decimal_segments=32'h403f064f;
            -12:decimal_segments=32'h403f065b;
            -11:decimal_segments=32'h403f0606;
            -10:decimal_segments=32'h403f063f;
            -9:decimal_segments=32'h403f3f6f;
            -8:decimal_segments=32'h403f3f7f;
            -7:decimal_segments=32'h403f3f07;
            -6:decimal_segments=32'h403f3f7d;
            -5:decimal_segments=32'h403f3f6d;
            -4:decimal_segments=32'h403f3f66;
            -3:decimal_segments=32'h403f3f4f;
            -2:decimal_segments=32'h403f3f5b;
            -1:decimal_segments=32'h403f3f06;
            0:decimal_segments=32'h3f3f3f3f;
            1:decimal_segments=32'h3f3f3f06;
            2:decimal_segments=32'h3f3f3f5b;
            3:decimal_segments=32'h3f3f3f4f;
            4:decimal_segments=32'h3f3f3f66;
            5:decimal_segments=32'h3f3f3f6d;
            6:decimal_segments=32'h3f3f3f7d;
            7:decimal_segments=32'h3f3f3f07;
            8:decimal_segments=32'h3f3f3f7f;
            9:decimal_segments=32'h3f3f3f6f;
            10:decimal_segments=32'h3f3f063f;
            11:decimal_segments=32'h3f3f0606;
            12:decimal_segments=32'h3f3f065b;
            13:decimal_segments=32'h3f3f064f;
            14:decimal_segments=32'h3f3f0666;
            15:decimal_segments=32'h3f3f066d;
            16:decimal_segments=32'h3f3f067d;
            17:decimal_segments=32'h3f3f0607;
            18:decimal_segments=32'h3f3f067f;
            19:decimal_segments=32'h3f3f066f;
            20:decimal_segments=32'h3f3f5b3f;
            21:decimal_segments=32'h3f3f5b06;
            22:decimal_segments=32'h3f3f5b5b;
            23:decimal_segments=32'h3f3f5b4f;
            24:decimal_segments=32'h3f3f5b66;
            25:decimal_segments=32'h3f3f5b6d;
            26:decimal_segments=32'h3f3f5b7d;
            27:decimal_segments=32'h3f3f5b07;
            28:decimal_segments=32'h3f3f5b7f;
            29:decimal_segments=32'h3f3f5b6f;
            30:decimal_segments=32'h3f3f4f3f;
            default:decimal_segments=32'hxxxxxxxx;
        endcase
    endfunction
    function [31:0] expected_segments(input signed [5:0] r,input binary_mode);
        integer n;
        begin
            expected_segments=decimal_segments(r);
            if(binary_mode) for(n=0;n<4;n=n+1)
                expected_segments[n*8+:8]=r[n]?8'h06:8'h3f;
        end
    endfunction
    task settle;repeat(12) @(negedge clk);endtask
    task press(input integer n);
        begin btn[n]=1;settle;btn[n]=0;settle;end
    endtask
    task check_hold;
        begin
            if(dut.result_q!==held || dut.binary_q!==held_binary) $fatal(1,"Cambio sin ejecutar, stage=%0d",stage);
            checks=checks+1;
        end
    endtask
    task display_check;
        reg [31:0] before_frames;
        begin
            before_frames=frames;wait(frames>=before_frames+2);#1000;
            if(received!==expected_segments(held,held_binary)) $fatal(1,"Display no corresponde a ultimo resultado");
        end
    endtask
    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0,stage,sw,sw_sel,btn,led,rgb_r,rgb_g,rgb_b,
            dut.data_sw,dut.btn_edge,dut.wr_addr,dut.sel_a,dut.sel_b,
            dut.op_a,dut.op_b,dut.op_sel,dut.alu_out,dut.result_q,dut.binary_q,
            dut.u_regs.reg_a,dut.u_regs.reg_b,dut.u_regs.reg_c,dut.u_regs.reg_d,
            received,frames);
        settle;
        if(led!==0 || {rgb_r,rgb_g,rgb_b}!==4 || dut.result_q!==0) $fatal(1,"Inicio top");
        if(dut.alu_out!==0) $fatal(1,"ALU inicial debe valer cero sin mover switches");
        press(3);check_hold; // Ejecutar 0+0 sin cambiar ninguna entrada de la ALU.
        stage=1;
        // Escrituras independientes usando solamente los cuatro switches de placa.
        model_regs[0]=5;model_regs[1]=3;model_regs[2]=10;model_regs[3]=15;
        for(i=0;i<4;i=i+1) begin
            sw=model_regs[i];settle;press(1);check_hold;press(0);
        end
        if(dut.wr_addr!==0 || dut.u_regs.reg_a!==5 || dut.u_regs.reg_b!==3 ||
           dut.u_regs.reg_c!==10 || dut.u_regs.reg_d!==15) $fatal(1,"Carga banco completo");
        stage=2;press(2); // R0,R1
        for(k=0;k<4;k=k+1) begin
            sw_sel=k;settle;check_hold;press(3);
            held=reference_alu(5,3,k);held_binary=k>=2;
            if(dut.result_q!==held || dut.binary_q!==held_binary) $fatal(1,"Operacion dirigida %0d",k);
            display_check;
        end
        stage=3;
        // Todos los pares y operaciones; selector ya esta en indice 1.
        for(i=1;i<=16;i=i+1) begin
            if({dut.sel_a,dut.sel_b} !== (i%16)) $fatal(1,"Par top");
            if(led!==(i%16)) $fatal(1,"LED top");
            for(k=0;k<4;k=k+1) begin
                sw_sel=k;settle;check_hold;
                expected=reference_alu(model_regs[(i%16)/4],model_regs[i%4],k);
                press(3);held=expected;held_binary=k>=2;
                if(dut.result_q!==expected) $fatal(1,"Par=%0d op=%0d",i%16,k);
                checks=checks+1;
                display_check;
            end
            press(2);check_hold;
        end
        stage=4;
        // Reescribir R0 y cambiar operacion/pareja no actualiza resultado.
        sw=9;settle;press(1);check_hold;
        sw_sel=0;settle;press(2);check_hold;display_check;
        stage=5;
        // Mantener BTN3: el primer flanco ejecuta, cambios posteriores no repiten.
        btn[3]=1;settle;held=dut.alu_out;held_binary=sw_sel[1];check_hold;
        sw_sel=3;settle;check_hold;display_check;
        press(2);check_hold;
        btn[3]=0;settle;check_hold;
        stage=6;
        // Rebote corto BTN0/1/2/3: ningun pulso aceptado.
        for(i=0;i<4;i=i+1) begin
            btn[i]=1;@(negedge clk);btn[i]=0;settle;check_hold;
        end
        stage=7;sw=15;settle;press(3);held=dut.alu_out;held_binary=sw_sel[1];check_hold;
        // Ningun switch de datos selecciona la operacion externa.
        for(k=0;k<16;k=k+1) begin
            sw=k;settle;check_hold;
            if(dut.op_sel!==3 || dut.alu_out!==15) $fatal(1,"Dato altera opcode externo");
            checks=checks+1;
        end
        display_check;
        stage=8;
        // Pulsos simultaneos: todos los registros consumen el estado PREVIO.
        sw=6;settle;btn=4'b0011;settle;btn=0;settle;check_hold;
        if(dut.wr_addr!==1 || dut.u_regs.reg_a!==6 || dut.u_regs.reg_b!==3)
            $fatal(1,"Direccion+escritura simultaneas");
        press(0);press(0);press(0); // volver a destino R0
        sw=4;sw_sel=3;settle;btn=4'b1010;settle;btn=0;settle;held=15;held_binary=1;
        if(dut.result_q!==15 || dut.u_regs.reg_a!==4 || dut.alu_out!==15)
            $fatal(1,"Escritura+ejecucion debe leer operando anterior");
        sw=1;sw_sel=1;settle;btn=4'b1100;settle;btn=0;settle;held=-11;held_binary=0;
        if(dut.result_q!==-11 || {dut.sel_a,dut.sel_b}!==4 || dut.alu_out!==-1)
            $fatal(1,"Selector+ejecucion debe usar pareja anterior");
        display_check;
        $display("PASS TOP: 4 registros, 16 pares x 4 operaciones, %0d comprobaciones, display serial y retencion",checks);
        $finish;
    end
    initial begin #200_000_000;$fatal(1,"Timeout top");end
endmodule
