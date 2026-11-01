`timescale 1ns / 1ps
// ============================================================================
// tm1637_driver
// ----------------------------------------------------------------------------
// Envia continuamente 4 bytes de segmentos a un modulo TM1637 de 4 digitos.
// No decide QUE se muestra: eso lo hace display_formatter. Asi se puede
// cambiar la representacion (binario, decimal, hex) sin tocar el protocolo.
//
//  * Sin reset: todos los registros tienen valor inicial (el bitstream los
//    carga). La pantalla se refresca sin parar, asi que cualquier trama
//    perdida al encender se corrige en la siguiente.
//  * Trama: START 0x40 STOP | START 0xC0 d0 d1 d2 d3 STOP | START 0x88|BRIGHT STOP
//  * 'segments' se captura al inicio de cada trama: los 4 digitos enviados
//    siempre corresponden al mismo valor.
//  * DIO open-drain: solo se lleva a 0 o se suelta (pull-up del modulo).
//    Conectar mediante adaptador 3.3/5 V si el modulo requiere 5 V.
//    Consultar docs/montaje_y_prueba.md; nunca elevar el Pmod a 5 V.
// ============================================================================
`default_nettype none
module tm1637_driver #(
    parameter integer CLK_HZ = 125_000_000,  // reloj de la FPGA (Zybo Z7: 125 MHz)
    parameter integer BIT_HZ = 100_000,      // frecuencia de CLK del TM1637 (< 250 kHz)
    parameter [2:0]   BRIGHT = 3'd7          // brillo 0..7
)(
    input  wire        clk,
    input  wire [31:0] segments,   // {dig0, dig1, dig2, dig3}; dig0 = digito izquierdo
    output reg         tm_clk  = 1'b1,
    inout  wire        tm_dio,
    output reg         ack_err = 1'b0   // 1 si el TM1637 no respondio ACK (debug)
);

    // ------------------------------------------------------------------------
    // Base de tiempo: 4 ticks por bit
    // ------------------------------------------------------------------------
    localparam integer DIV_RAW = (CLK_HZ + 4 * BIT_HZ - 1) / (4 * BIT_HZ);
    localparam integer DIV     = (DIV_RAW < 1) ? 1 : DIV_RAW;
    localparam integer GAP     = 8;          // ticks en reposo entre tramas

    localparam integer DIV_W = (DIV < 2) ? 1 : $clog2(DIV);
    reg [DIV_W-1:0] div_cnt = 0;
    reg        tick    = 1'b0;

    always @(posedge clk) begin
        if (div_cnt == DIV - 1) begin
            div_cnt <= 32'd0;
            tick    <= 1'b1;
        end else begin
            div_cnt <= div_cnt + 1'b1;
            tick    <= 1'b0;
        end
    end

    // ACK asincrono: dos etapas; se muestrea al final del nivel alto.
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    reg dio_meta = 1'b1, dio_sync = 1'b1;
    reg frame_error = 1'b0;
    always @(posedge clk) begin
        dio_meta <= tm_dio;
        dio_sync <= dio_meta;
    end

    // ------------------------------------------------------------------------
    // Bytes de la trama
    // ------------------------------------------------------------------------
    reg  [31:0] seg_q = 32'd0;   // segmentos capturados en la trama actual
    reg  [2:0]  idx   = 3'd0;
    reg  [7:0]  cur_byte;
    wire        last  = (idx == 3'd0) || (idx == 3'd5) || (idx == 3'd6);

    always @* begin
        case (idx)
            3'd0:    cur_byte = 8'h40;                 // escribir, auto-incremento
            3'd1:    cur_byte = 8'hC0;                 // direccion inicial (GRID1)
            3'd2:    cur_byte = seg_q[31:24];          // digito 0 (izquierda)
            3'd3:    cur_byte = seg_q[23:16];
            3'd4:    cur_byte = seg_q[15:8];
            3'd5:    cur_byte = seg_q[7:0];            // digito 3 (derecha)
            default: cur_byte = {5'b10001, BRIGHT};    // display ON + brillo
        endcase
    end

    // ------------------------------------------------------------------------
    // Maquina de estados del bus de 2 hilos
    // ------------------------------------------------------------------------
    localparam [2:0] S_IDLE  = 3'd0,
                     S_START = 3'd1,
                     S_BIT   = 3'd2,
                     S_ACK   = 3'd3,
                     S_STOP  = 3'd4;

    reg [2:0] state   = S_IDLE;
    reg [1:0] ph      = 2'd0;    // fase dentro del bit
    reg [2:0] bit_i   = 3'd0;    // bit actual (LSB primero)
    reg [7:0] gap_cnt = 8'd0;
    reg       dio_low = 1'b0;    // 1: forzar DIO a 0, 0: soltar (alta impedancia)

    assign tm_dio = dio_low ? 1'b0 : 1'bz;

    always @(posedge clk) begin
        if (tick) begin
            ph <= ph + 2'd1;
            case (state)
                // Bus en reposo (CLK=1, DIO=1); se captura el valor a mostrar
                S_IDLE: begin
                    tm_clk  <= 1'b1;
                    dio_low <= 1'b0;
                    ph      <= 2'd0;
                    if (gap_cnt == GAP - 1) begin
                        gap_cnt <= 8'd0;
                        idx     <= 3'd0;
                        seg_q   <= segments;
                        frame_error <= 1'b0;
                        state   <= S_START;
                    end else
                        gap_cnt <= gap_cnt + 8'd1;
                end

                // START: DIO baja mientras CLK esta en alto
                S_START: case (ph)
                    2'd0: begin tm_clk <= 1'b1; dio_low <= 1'b0; end
                    2'd1: dio_low <= 1'b1;
                    2'd2: tm_clk  <= 1'b0;
                    2'd3: begin bit_i <= 3'd0; state <= S_BIT; end
                endcase

                // 8 bits, LSB primero; DIO cambia solo con CLK en bajo
                S_BIT: case (ph)
                    2'd0: tm_clk  <= 1'b0;
                    2'd1: dio_low <= ~cur_byte[bit_i];
                    2'd2: tm_clk  <= 1'b1;
                    2'd3: begin
                        if (bit_i == 3'd7) state <= S_ACK;
                        bit_i <= bit_i + 3'd1;
                    end
                endcase

                // 9.o pulso: se suelta DIO y el TM1637 lo baja (ACK)
                S_ACK: case (ph)
                    2'd0: tm_clk  <= 1'b0;
                    2'd1: dio_low <= 1'b0;
                    2'd2: tm_clk <= 1'b1;
                    2'd3: begin
                        frame_error <= frame_error | dio_sync;
                        if (idx == 3'd6) ack_err <= frame_error | dio_sync;
                        if (last) state <= S_STOP;
                        else begin
                            idx   <= idx + 3'd1;
                            state <= S_BIT;
                        end
                    end
                endcase

                // STOP: DIO sube mientras CLK esta en alto
                S_STOP: case (ph)
                    2'd0: tm_clk  <= 1'b0;
                    2'd1: dio_low <= 1'b1;
                    2'd2: tm_clk  <= 1'b1;
                    2'd3: begin
                        dio_low <= 1'b0;
                        if (idx == 3'd6) state <= S_IDLE;
                        else begin
                            idx   <= idx + 3'd1;
                            state <= S_START;
                        end
                    end
                endcase

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
`default_nettype wire
