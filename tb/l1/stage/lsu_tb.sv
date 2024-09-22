`timescale 1ns / 1ps

`include "cfg.sv"

module lsu_tb();

initial begin
    $dumpfile("build/lsu_tb.vcd");
    $dumpvars(0, lsu_tb);
end

parameter CYCLE      = 10;
parameter DATA_WIDTH = 32;

initial begin
    $finish;
end

lsu #(
    .DATA_WIDTH(DATA_WIDTH)
) u_lsu(
    .i_sys_ready        (),
    .o_sys_valid        (),
    .i_idu_ctr_ram_byt  (),
    .i_exu_res          (),
    .i_ram_rd_data      (),
    .o_lsu_ram_rd_en    (),
    .o_lsu_ram_rd_addr  (),
    .o_lsu_gpr_wr_data  (),
    .i_idu_ctr_ram_wr_en(),
    .i_gpr_rs2_data     (),
    .o_lsu_ram_wr_en    (),
    .o_lsu_ram_wr_addr  (),
    .o_lsu_ram_wr_data  (),
    .o_lsu_ram_wr_mask  ()
);

endmodule
