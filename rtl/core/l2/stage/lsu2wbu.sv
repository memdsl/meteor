module lsu2wbu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,
    input  logic                       i_sys_ready,
    output logic                       o_sys_valid,

    input  logic                       i_lsu_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_lsu_ctr_reg_wr_src,
    input  logic [`ADDR_WIDTH - 1 : 0] i_lsu_pc,
    input  logic [`DATA_WIDTH - 1 : 0] i_lsu_alu_res,
    input  logic [`DATA_WIDTH - 1 : 0] i_lsu_ram_res,
    input  logic [`lsuS_WIDTH - 1 : 0] i_lsu_wr_id,
    input  logic                       o_lsu_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] o_lsu_ctr_reg_wr_src,
    input  logic [`ADDR_WIDTH - 1 : 0] o_lsu_pc,
    input  logic [`DATA_WIDTH - 1 : 0] o_exu_res,
    input  logic [`DATA_WIDTH - 1 : 0] o_lsu_res,
    input  logic [`lsuS_WIDTH - 1 : 0] o_lsu_wr_id
);

    assign o_sys_valid = 1'b1;

    logic                       r_lsu_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] r_lsu_ctr_reg_wr_src;
    logic [`ADDR_WIDTH - 1 : 0] r_lsu_pc;
    logic [`DATA_WIDTH - 1 : 0] r_exu_res;
    logic [`DATA_WIDTH - 1 : 0] r_lsu_res;
    logic [`lsuS_WIDTH - 1 : 0] r_lsu_wr_id;

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_lsu_ctr_reg_wr_en  <= 1'b0;
            r_lsu_ctr_reg_wr_src <= `REG_WR_SRC_X;
            r_lsu_pc             <= `ADDR_INIT;
            r_exu_res            <= `DATA_ZERO;
            r_lsu_res            <= `DATA_ZERO;
            r_lsu_wr_id          <= `lsuS_ZERO;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_lsu_ctr_reg_wr_en  <= i_lsu_ctr_reg_wr_en;
            r_lsu_ctr_reg_wr_src <= i_lsu_ctr_reg_wr_src;
            r_lsu_pc             <= i_lsu_pc;
            r_exu_res            <= i_lsu_alu_res;
            r_lsu_res            <= i_lsu_ram_res;
            r_lsu_wr_id          <= i_lsu_wr_id;
        end
        else begin
            r_lsu_ctr_reg_wr_en  <= r_lsu_ctr_reg_wr_en;
            r_lsu_ctr_reg_wr_src <= r_lsu_ctr_reg_wr_src;
            r_lsu_pc             <= r_lsu_pc;
            r_exu_res            <= r_exu_res;
            r_lsu_res            <= r_lsu_res;
            r_lsu_wr_id          <= r_lsu_wr_id;
        end
    end

    assign o_lsu_ctr_reg_wr_en  = r_lsu_ctr_reg_wr_en;
    assign o_lsu_ctr_reg_wr_src = r_lsu_ctr_reg_wr_src;
    assign o_lsu_pc             = r_lsu_pc;
    assign o_exu_res            = r_exu_res;
    assign o_lsu_res            = r_lsu_res;
    assign o_lsu_wr_id          = r_lsu_wr_id;

endmodule
