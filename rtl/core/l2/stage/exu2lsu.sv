module exu2lsu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,

    input  logic                       i_exu_valid,
    output logic                       o_e2l_ready,
    input  logic                       i_lsu_ready,
    output logic                       o_e2l_valid,

    input  logic [`ADDR_WIDTH - 1 : 0] i_exu_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_e2l_pc,

    input  logic                       i_exu_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_exu_ctr_reg_wr_src,
    input  logic [`GPRS_WIDTH - 1 : 0] i_exu_gpr_rd_id,
    output logic                       o_e2l_ctr_reg_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_e2l_ctr_reg_wr_src,
    output logic [`GPRS_WIDTH - 1 : 0] o_e2l_gpr_rd_id,

    input  logic [`ARGS_WIDTH - 1 : 0] i_exu_ctr_inst_type,
    input  logic [`ARGS_WIDTH - 1 : 0] i_exu_ctr_ram_byt,
    input  logic                       i_exu_ctr_ram_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_e2l_ctr_inst_type,
    output logic [`ARGS_WIDTH - 1 : 0] o_e2l_ctr_ram_byt,
    output logic                       o_e2l_ctr_ram_wr_en,

    input  logic [`DATA_WIDTH  - 1 : 0] i_exu_res,
    input  logic [`DATA_WIDTH  - 1 : 0] i_exu_rs2_data,
    output logic [`DATA_WIDTH  - 1 : 0] o_e2l_res,
    output logic [`DATA_WIDTH  - 1 : 0] o_e2l_rs2_data
);

    assign o_e2l_ready = 1'b1;
    assign o_e2l_valid = 1'b1;

    logic [`ADDR_WIDTH - 1 : 0] r_e2l_pc;
    logic                       r_e2l_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] r_e2l_ctr_reg_wr_src;
    logic [`GPRS_WIDTH - 1 : 0] r_e2l_gpr_rd_id;
    logic [`ARGS_WIDTH - 1 : 0] r_e2l_ctr_inst_type;
    logic [`ARGS_WIDTH - 1 : 0] r_e2l_ctr_ram_byt;
    logic                       r_e2l_ctr_ram_wr_en;
    logic [`DATA_WIDTH - 1 : 0] r_e2l_res;
    logic [`DATA_WIDTH - 1 : 0] r_e2l_rs2_data;

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_e2l_pc <= `ADDR_INIT;
        end
        else if (o_e2l_ready && i_exu_valid) begin
            r_e2l_pc <= i_exu_pc;
        end
        else begin
            r_e2l_pc <= r_e2l_pc;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_e2l_ctr_reg_wr_en  <= 1'b0;
            r_e2l_ctr_reg_wr_src <= `REG_WR_SRC_X;
            r_e2l_gpr_rd_id      <= `GPRS_ZERO;
        end
        else if (o_e2l_ready && i_exu_valid) begin
            r_e2l_ctr_reg_wr_en  <= i_exu_ctr_reg_wr_en;
            r_e2l_ctr_reg_wr_src <= i_exu_ctr_reg_wr_src;
            r_e2l_gpr_rd_id      <= i_exu_gpr_rd_id;
        end
        else begin
            r_e2l_ctr_reg_wr_en  <= r_e2l_ctr_reg_wr_en;
            r_e2l_ctr_reg_wr_src <= r_e2l_ctr_reg_wr_src;
            r_e2l_gpr_rd_id      <= r_e2l_gpr_rd_id;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_e2l_ctr_inst_type <= `INST_TYPE_X;
            r_e2l_ctr_ram_byt   <= `RAM_BYT_X;
            r_e2l_ctr_ram_wr_en <= 1'b0;
        end
        else if (o_e2l_ready && i_exu_valid) begin
            r_e2l_ctr_inst_type <= i_exu_ctr_inst_type;
            r_e2l_ctr_ram_byt   <= i_exu_ctr_ram_byt;
            r_e2l_ctr_ram_wr_en <= i_exu_ctr_ram_wr_en;
        end
        else begin
            r_e2l_ctr_inst_type <= r_e2l_ctr_inst_type;
            r_e2l_ctr_ram_byt   <= r_e2l_ctr_ram_byt;
            r_e2l_ctr_ram_wr_en <= r_e2l_ctr_ram_wr_en;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_e2l_res      <= `DATA_ZERO;
            r_e2l_rs2_data <= `DATA_ZERO;
        end
        else if (o_e2l_ready && i_exu_valid) begin
            r_e2l_res      <= i_exu_res;
            r_e2l_rs2_data <= i_exu_rs2_data;
        end
        else begin
            r_e2l_res      <= r_e2l_res;
            r_e2l_rs2_data <= r_e2l_rs2_data;
        end
    end

    assign o_e2l_pc             = r_e2l_pc;
    assign o_e2l_ctr_reg_wr_en  = r_e2l_ctr_reg_wr_en;
    assign o_e2l_ctr_reg_wr_src = r_e2l_ctr_reg_wr_src;
    assign o_e2l_gpr_rd_id      = r_e2l_gpr_rd_id;
    assign o_e2l_ctr_inst_type  = r_e2l_ctr_inst_type;
    assign o_e2l_ctr_ram_byt    = r_e2l_ctr_ram_byt;
    assign o_e2l_ctr_ram_wr_en  = r_e2l_ctr_ram_wr_en;
    assign o_e2l_res            = r_e2l_res;
    assign o_e2l_rs2_data       = r_e2l_rs2_data;

endmodule
