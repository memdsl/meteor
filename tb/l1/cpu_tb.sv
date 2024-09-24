`timescale 1ns / 1ps

`include "cfg.sv"

module cpu_tb();

initial begin
    $dumpfile("build/cpu_tb.vcd");
    $dumpvars(0, cpu_tb);
end

parameter CYCLE      = 10;
parameter DATA_WIDTH = 32;

logic w_clk;
logic w_rst_n;

always #(CYCLE / 2) w_clk = ~w_clk;

initial begin
    w_clk    = 1'h0;
    w_rst_n  = 1'h0;
    #(CYCLE * 100);
    $finish;
end

cpu #(
    .DATA_WIDTH(DATA_WIDTH)
) u_cpu(
    .i_sys_clk  (w_clk),
    .i_sys_rst_n(w_rst_n)
);

endmodule
