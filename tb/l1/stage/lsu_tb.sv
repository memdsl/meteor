`timescale 1ns / 1ps

`include "cfg.sv"

module lsu_tb();

initial begin
    $dumpfile("build/lsu_tb.vcd");
    $dumpvars(0, lsu_tb);
end

parameter CYCLE      = 10;
parameter DATA_WIDTH = 32;

logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_ram_byt;

initial begin
    w_idu_ctr_ram_byt = `RAM_BYT_1_S;
    #(CYCLE * 5);
    w_idu_ctr_ram_byt = `RAM_BYT_1_U;
    #(CYCLE * 5);
    w_idu_ctr_ram_byt = `RAM_BYT_2_S;
    #(CYCLE * 5);
    w_idu_ctr_ram_byt = `RAM_BYT_2_U;
    #(CYCLE * 5);
    w_idu_ctr_ram_byt = `RAM_BYT_4_S;
    #(CYCLE * 5);
    w_idu_ctr_ram_byt = `RAM_BYT_4_U;
    #(CYCLE * 5);
    $finish;
end

lsu #(
    .DATA_WIDTH(DATA_WIDTH)
) u_lsu(
    .i_sys_ready        ( 1'h1),
    .o_sys_valid        (),
    .i_idu_ctr_ram_byt  (w_idu_ctr_ram_byt),
    .i_exu_res          (32'h1),
    .i_ram_rd_data      (32'hffff_ffff),
    .o_lsu_ram_rd_en    (),
    .o_lsu_ram_rd_addr  (),
    .o_lsu_gpr_wr_data  (),
    .i_idu_ctr_ram_wr_en( 1'h1),
    .i_gpr_rs2_data     (32'h1),
    .o_lsu_ram_wr_en    (),
    .o_lsu_ram_wr_addr  (),
    .o_lsu_ram_wr_data  (),
    .o_lsu_ram_wr_mask  ()
);

endmodule
