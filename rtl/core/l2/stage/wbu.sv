module wbu(
    input  logic                       i_l2w_valid,
    output logic                       o_wbu_ready,
    input  logic                       i_ifu_ready,
    output logic                       o_wbu_valid,

    input  logic                       i_l2w_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_l2w_ctr_reg_wr_src,
    input  logic [`ADDR_WIDTH - 1 : 0] i_l2w_pc,
    input  logic [`DATA_WIDTH - 1 : 0] i_l2w_alu_res,
    input  logic [`DATA_WIDTH - 1 : 0] i_l2w_ram_res,
    input  logic [`GPRS_WIDTH - 1 : 0] i_l2w_gpr_wr_id,
    output logic                       o_wbu_gpr_wr_en,
    output logic [`GPRS_WIDTH - 1 : 0] o_wbu_gpr_wr_id,
    output logic [`DATA_WIDTH - 1 : 0] o_wbu_gpr_wr_data,

    output logic                       o_wbu_pc_en
);

    assign o_wbu_ready = 1'b1;
    assign o_wbu_valid = 1'b1;

    assign o_wbu_gpr_wr_en   = (i_l2w_valid && o_wbu_ready) ? i_l2w_ctr_reg_wr_en : 1'b0;
    assign o_wbu_gpr_wr_id   = (i_l2w_valid && o_wbu_ready) ? i_l2w_gpr_wr_id         : 5'h0;
    assign o_wbu_gpr_wr_data = (i_l2w_valid && o_wbu_ready) ?
                              ((i_l2w_ctr_reg_wr_src === `REG_WR_SRC_ALU) ? i_l2w_alu_res     :
                               (i_l2w_ctr_reg_wr_src === `REG_WR_SRC_MEM) ? i_l2w_ram_res     :
                               (i_l2w_ctr_reg_wr_src === `REG_WR_SRC_PC ) ? i_l2w_pc  + 32'h4 :
                                                                           `DATA_ZERO)        : `DATA_ZERO;
    assign o_wbu_pc_en = 1'b1;

endmodule
