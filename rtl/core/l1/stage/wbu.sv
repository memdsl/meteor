`include "cfg.sv"

module wbu(
    input  logic                       i_sys_ready,
    output logic                       o_sys_valid,

    input  logic                       i_idu_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_reg_wr_src,
    input  logic [`ADDR_WIDTH - 1 : 0] i_ifu_pc,
    input  logic [`DATA_WIDTH - 1 : 0] i_exu_res,
    input  logic [`DATA_WIDTH - 1 : 0] i_ram_res,
    input  logic [`GPRS_WIDTH - 1 : 0] i_gpr_wr_id,
    output logic                       o_wbu_gpr_wr_en,
    output logic [`GPRS_WIDTH - 1 : 0] o_wbu_gpr_wr_id,
    output logic [`DATA_WIDTH - 1 : 0] o_wbu_gpr_wr_data
);

    assign o_sys_valid = 1'h1;

    assign o_wbu_gpr_wr_en = (o_sys_valid && i_sys_ready) ? i_idu_ctr_reg_wr_en : 1'h0;
    assign o_wbu_gpr_wr_id = (o_sys_valid && i_sys_ready) ? i_gpr_wr_id : 5'h0;
    always_comb begin
        if (o_sys_valid && i_sys_ready) begin
            o_wbu_gpr_wr_data =
                (i_idu_ctr_reg_wr_src === `REG_WR_SRC_ALU) ? i_exu_res :
                (i_idu_ctr_reg_wr_src === `REG_WR_SRC_MEM) ? i_ram_res :
                (i_idu_ctr_reg_wr_src === `REG_WR_SRC_PC)  ? i_ifu_pc  :
                                                            `DATA_ZERO;
        end
        else begin
            o_wbu_gpr_wr_data = `DATA_ZERO;
        end
    end

endmodule
