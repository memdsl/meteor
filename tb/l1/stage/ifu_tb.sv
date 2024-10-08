`timescale 1ns / 1ps

`include "cfg.sv"

module ifu_tb();

initial begin
    $dumpfile("build/ifu_tb.vcd");
    $dumpvars(0, ifu_tb);
end

parameter CYCLE = 10;

logic                       w_clk;
logic                       w_rst_n;
logic                       w_ready;
logic                       w_valid;
logic                       w_jmp_en;
logic [`ADDR_WIDTH - 1 : 0] w_jmp_pc;

always #(CYCLE / 2) w_clk = ~w_clk;

initial begin
    w_clk    = 1'h0;
    w_rst_n  = 1'h0;
    w_ready  = 1'h1;
    w_jmp_en = 1'h0;
    w_jmp_pc = 32'h8000_0000;
    #(CYCLE * 1);
    w_rst_n  = 1'h1;
    w_jmp_en = 1'h0;
    #(CYCLE * 5);
    w_jmp_en = 1'h1;
    w_jmp_pc = 32'h9000_0000;
    #(CYCLE * 5);
    w_jmp_en = 1'h0;
    w_jmp_pc = 32'h8000_0000;
    #(CYCLE * 5);
    $finish;
end

ifu u_ifu(
    .i_sys_clk    (w_clk),
    .i_sys_rst_n  (w_rst_n),
    .i_sys_ready  (w_ready),
    .o_sys_valid  (),
    .i_exu_jmp_en (w_jmp_en),
    .i_exu_jmp_pc (w_jmp_pc),
    .o_ifu_pc     (),
    .o_ifu_pc_next()
);

endmodule
