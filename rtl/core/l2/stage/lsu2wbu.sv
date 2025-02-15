module lsu2wbu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,
    input  logic                       i_sys_ready,
    output logic                       o_sys_valid,

    input  logic                       i_idu_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_reg_wr_src,
    input  logic [`ADDR_WIDTH - 1 : 0] i_ifu_pc,
    input  logic [`DATA_WIDTH - 1 : 0] i_exu_res,
    input  logic [`DATA_WIDTH - 1 : 0] i_lsu_res,
    input  logic [`GPRS_WIDTH - 1 : 0] i_gpr_wr_id,
    input  logic                       o_idu_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_reg_wr_src,
    input  logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc,
    input  logic [`DATA_WIDTH - 1 : 0] o_exu_res,
    input  logic [`DATA_WIDTH - 1 : 0] o_lsu_res,
    input  logic [`GPRS_WIDTH - 1 : 0] o_gpr_wr_id
);

    assign o_sys_valid = 1'b1;

    logic                       r_idu_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_reg_wr_src;
    logic [`ADDR_WIDTH - 1 : 0] r_ifu_pc;
    logic [`DATA_WIDTH - 1 : 0] r_exu_res;
    logic [`DATA_WIDTH - 1 : 0] r_lsu_res;
    logic [`GPRS_WIDTH - 1 : 0] r_gpr_wr_id;

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_idu_ctr_reg_wr_en  <= 1'b0;
            r_idu_ctr_reg_wr_src <= `REG_WR_SRC_X;
            r_ifu_pc             <= `ADDR_INIT;
            r_exu_res            <= `DATA_ZERO;
            r_lsu_res            <= `DATA_ZERO;
            r_gpr_wr_id          <= `GPRS_ZERO;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_idu_ctr_reg_wr_en  <= i_idu_ctr_reg_wr_en;
            r_idu_ctr_reg_wr_src <= i_idu_ctr_reg_wr_src;
            r_ifu_pc             <= i_ifu_pc;
            r_exu_res            <= i_exu_res;
            r_lsu_res            <= i_lsu_res;
            r_gpr_wr_id          <= i_gpr_wr_id;
        end
        else begin
            r_idu_ctr_reg_wr_en  <= r_idu_ctr_reg_wr_en;
            r_idu_ctr_reg_wr_src <= r_idu_ctr_reg_wr_src;
            r_ifu_pc             <= r_ifu_pc;
            r_exu_res            <= r_exu_res;
            r_lsu_res            <= r_lsu_res;
            r_gpr_wr_id          <= r_gpr_wr_id;
        end
    end

    assign o_idu_ctr_reg_wr_en  = r_idu_ctr_reg_wr_en;
    assign o_idu_ctr_reg_wr_src = r_idu_ctr_reg_wr_src;
    assign o_ifu_pc             = r_ifu_pc;
    assign o_exu_res            = r_exu_res;
    assign o_lsu_res            = r_lsu_res;
    assign o_gpr_wr_id          = r_gpr_wr_id;

endmodule
