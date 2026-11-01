`timescale 1ns/1ps
`default_nettype none
module debouncer #(parameter integer STABLE_CYCLES = 1_250_000)(
    input wire clk, btn_in, output reg btn_out = 0);
    localparam integer N = (STABLE_CYCLES < 1) ? 1 : STABLE_CYCLES;
    localparam integer W = (N < 2) ? 1 : $clog2(N);
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    reg btn_sync_0 = 0, btn_sync_1 = 0;
    reg [W-1:0] counter = 0;
    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
        if (btn_sync_1 == btn_out) counter <= 0;
        else if (counter == N-1) begin
            btn_out <= btn_sync_1;
            counter <= 0;
        end else counter <= counter + 1'b1;
    end
endmodule
`default_nettype wire
