`timescale 1ns/1ps
`default_nettype none
// Zybo Z7-10. Solo PL, sin PS/Vitis. Todos los registros usan clk de 125 MHz.
module top #(
    parameter integer CLK_HZ = 125_000_000,
    parameter integer DEBOUNCE_CYCLES = 1_250_000,
    parameter integer TM_BIT_HZ = 100_000
)(input wire clk, input wire [3:0] sw, btn, input wire [1:0] sw_sel,
    output wire [3:0] led, output wire rgb_r, rgb_g, rgb_b,
    output wire tm_clk, inout wire tm_dio);
    wire [3:0] data_sw, btn_db, btn_edge;
    wire [1:0] op_sel;
    wire [1:0] wr_addr, sel_a, sel_b;
    wire [3:0] op_a, op_b;
    wire signed [5:0] alu_out, result_q;
    wire [2:0] rgb;
    wire binary_q;
    wire ack_err; // Diagnostico en simulacion; no ocupa LEDs de registros.
    sync_inputs u_sw_sync(.clk(clk), .async_in(sw), .synced(data_sw));
    sync_inputs #(.WIDTH(2)) u_op_sync(.clk(clk), .async_in(sw_sel), .synced(op_sel));
    genvar i;
    generate for (i=0; i<4; i=i+1) begin : g_btn
        debouncer #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) u_db(
            .clk(clk), .btn_in(btn[i]), .btn_out(btn_db[i]));
        edge_detector u_edge(.clk(clk), .sig_in(btn_db[i]), .out(btn_edge[i]));
    end endgenerate
    address u_addr(.clk(clk), .btn0_rising_edge(btn_edge[0]), .address(wr_addr));
    comb_selector u_comb(.clk(clk), .btn2_rising_edge(btn_edge[2]),
        .sel_a(sel_a), .sel_b(sel_b));
    reg_bank u_regs(.clk(clk), .data_in(data_sw), .address(wr_addr),
        .write_enable(btn_edge[1]), .sel_a(sel_a), .sel_b(sel_b),
        .reg_a_out(op_a), .reg_b_out(op_b));
    alu u_alu(.a(op_a), .b(op_b), .sel(op_sel), .out(alu_out));
    result_register u_result(.clk(clk), .execute(btn_edge[3]),
        .alu_result(alu_out), .result_q(result_q),
        .binary_mode(op_sel[1]), .binary_q(binary_q));
    display_tm1637 #(.CLK_HZ(CLK_HZ), .BIT_HZ(TM_BIT_HZ)) u_display(
        .clk(clk), .result(result_q), .tm_clk(tm_clk), .tm_dio(tm_dio),
        .ack_err(ack_err), .binary_mode(binary_q));
    indicators u_indicators(.wr_addr(wr_addr), .sel_a(sel_a), .sel_b(sel_b),
        .led(led), .rgb(rgb));
    assign {rgb_r,rgb_g,rgb_b} = rgb;
endmodule
`default_nettype wire
