`include "../../../base/cfg.sv"

module wbu #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                       i_ready,
    output logic                       o_valid,

    input  logic                       i_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_reg_wr_src,

    input  logic [`ADDR_WIDTH - 1 : 0] i_pc,
    input  logic [ DATA_WIDTH - 1 : 0] i_alu_res,
    input  logic [ DATA_WIDTH - 1 : 0] i_ram_res,

    input  logic [`GPRS_WIDTH - 1 : 0] i_gpr_wr_id,
    output logic                       o_gpr_wr_en,
    output logic [`GPRS_WIDTH - 1 : 0] o_gpr_wr_id,
    output logic [ DATA_WIDTH - 1 : 0] o_gpr_wr_data

);

    assign o_valid = 1'h1;

    assign o_gpr_wr_en = (o_valid && i_ready) ? i_reg_wr_en : 1'h0;
    assign o_gpr_wr_id = (o_valid && i_ready) ? i_gpr_wr_id : 5'h0;
    always_comb begin
        if (o_valid && i_ready) begin
            o_gpr_wr_data = (i_reg_wr_src === `REG_WR_SRC_ALU) ? i_alu_res :
                            (i_reg_wr_src === `REG_WR_SRC_MEM) ? i_ram_res :
                            (i_reg_wr_src === `REG_WR_SRC_PC)  ? i_pc      :
                                                                 {DATA_WIDTH{1'h0}};
        end
        else begin
            o_gpr_wr_data = {DATA_WIDTH{1'h0}};
        end
    end

endmodule
