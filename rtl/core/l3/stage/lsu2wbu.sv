module lsu2wbu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,

    input  logic                       i_lsu_valid,
    output logic                       o_l2w_ready,
    input  logic                       i_wbu_ready,
    output logic                       o_l2w_valid,

    input  logic                       i_lsu_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_lsu_ctr_reg_wr_src,
    input  logic [`ADDR_WIDTH - 1 : 0] i_lsu_pc,
    input  logic [`DATA_WIDTH - 1 : 0] i_lsu_alu_res,
    input  logic [`DATA_WIDTH - 1 : 0] i_lsu_ram_res,
    input  logic [`GPRS_WIDTH - 1 : 0] i_lsu_gpr_wr_id,
    output logic                       o_l2w_ctr_reg_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_l2w_ctr_reg_wr_src,
    output logic [`ADDR_WIDTH - 1 : 0] o_l2w_pc,
    output logic [`DATA_WIDTH - 1 : 0] o_l2w_alu_res,
    output logic [`DATA_WIDTH - 1 : 0] o_l2w_ram_res,
    output logic [`GPRS_WIDTH - 1 : 0] o_l2w_gpr_wr_id
);

    assign o_l2w_ready = 1'b1;
    assign o_l2w_valid = 1'b1;

    logic                       r_l2w_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] r_l2w_ctr_reg_wr_src;
    logic [`ADDR_WIDTH - 1 : 0] r_l2w_pc;
    logic [`DATA_WIDTH - 1 : 0] r_l2w_alu_res;
    logic [`DATA_WIDTH - 1 : 0] r_l2w_ram_res;
    logic [`GPRS_WIDTH - 1 : 0] r_l2w_gpr_wr_id;

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_l2w_ctr_reg_wr_en  <= 1'b0;
            r_l2w_ctr_reg_wr_src <= `REG_WR_SRC_X;
            r_l2w_pc             <= `ADDR_INIT;
            r_l2w_alu_res        <= `DATA_ZERO;
            r_l2w_ram_res        <= `DATA_ZERO;
            r_l2w_gpr_wr_id      <= `GPRS_ZERO;
        end
        else if (i_lsu_valid && o_l2w_ready) begin
            r_l2w_ctr_reg_wr_en  <= i_lsu_ctr_reg_wr_en;
            r_l2w_ctr_reg_wr_src <= i_lsu_ctr_reg_wr_src;
            r_l2w_pc             <= i_lsu_pc;
            r_l2w_alu_res        <= i_lsu_alu_res;
            r_l2w_ram_res        <= i_lsu_ram_res;
            r_l2w_gpr_wr_id      <= i_lsu_gpr_wr_id;
        end
        else begin
            r_l2w_ctr_reg_wr_en  <= r_l2w_ctr_reg_wr_en;
            r_l2w_ctr_reg_wr_src <= r_l2w_ctr_reg_wr_src;
            r_l2w_pc             <= r_l2w_pc;
            r_l2w_alu_res        <= r_l2w_alu_res;
            r_l2w_ram_res        <= r_l2w_ram_res;
            r_l2w_gpr_wr_id      <= r_l2w_gpr_wr_id;
        end
    end

    assign o_l2w_ctr_reg_wr_en  = r_l2w_ctr_reg_wr_en;
    assign o_l2w_ctr_reg_wr_src = r_l2w_ctr_reg_wr_src;
    assign o_l2w_pc             = r_l2w_pc;
    assign o_l2w_alu_res        = r_l2w_alu_res;
    assign o_l2w_ram_res        = r_l2w_ram_res;
    assign o_l2w_gpr_wr_id      = r_l2w_gpr_wr_id;

endmodule
