`timescale 1ns / 1ps

`include "cfg.sv"

module wbu_tb();

parameter CYCLE      = 10;
parameter DATA_WIDTH = 32;

logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_reg_wr_src;

initial begin
    r_idu_ctr_reg_wr_src = `REG_WR_SRC_ALU;
    #(CYCLE * 5);
    r_idu_ctr_reg_wr_src = `REG_WR_SRC_MEM;
    #(CYCLE * 5);
    r_idu_ctr_reg_wr_src = `REG_WR_SRC_PC;
    #(CYCLE * 5);
    $finish;
end

wbu #(
    .DATA_WIDTH(DATA_WIDTH)
) u_wbu(
    .i_sys_ready         ( 1'h1),
    .o_sys_valid         (),
    .i_idu_ctr_reg_wr_en ( 1'h1),
    .i_idu_ctr_reg_wr_src(r_idu_ctr_reg_wr_src),
    .i_ifu_pc            (32'h8000_0000),
    .i_exu_res           (32'h1),
    .i_ram_res           (32'h2),
    .i_gpr_wr_id         ( 5'h1),
    .o_wbu_gpr_wr_en     (),
    .o_wbu_gpr_wr_id     (),
    .o_wbu_gpr_wr_data   ()
);

endmodule
