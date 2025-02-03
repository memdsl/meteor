`timescale 1ns / 1ps

`include "cfg.sv"

module ifu_tb();

initial begin
    $dumpfile("build/ifu_tb.vcd");
    $dumpvars(0, ifu_tb);
end

parameter CYCLE = 10;

logic                       r_clk;
logic                       r_rst_n;
logic                       r_ready;
logic                       r_valid;
logic                       r_jmp_en;
logic [`ADDR_WIDTH - 1 : 0] r_jmp_pc;

always #(CYCLE / 2) r_clk = ~r_clk;

initial begin
    r_clk    = 1'h0;
    r_rst_n  = 1'h0;
    r_ready  = 1'h1;
    r_jmp_en = 1'h0;
    r_jmp_pc = 32'h8000_0000;
    #(CYCLE * 1);
    r_rst_n  = 1'h1;
    r_jmp_en = 1'h0;
    #(CYCLE * 5);
    r_jmp_en = 1'h1;
    r_jmp_pc = 32'h9000_0000;
    #(CYCLE * 5);
    r_jmp_en = 1'h0;
    r_jmp_pc = 32'h8000_0000;
    #(CYCLE * 5);
    $finish;
end

ifu u_ifu(
    .i_sys_clk    (r_clk),
    .i_sys_rst_n  (r_rst_n),
    .i_sys_ready  (r_ready),
    .o_sys_valid  (),
    .i_exu_jmp_en (r_jmp_en),
    .i_exu_jmp_pc (r_jmp_pc),
    .o_ifu_pc     (),
    .o_ifu_pc_next()
);

endmodule
