module idu2exu(
    input  logic                       i_sys_clk,
    input  logic                       i_sys_rst_n,
    input  logic                       i_sys_ready,
    output logic                       o_sys_valid,

    input  logic [`ADDR_WIDTH - 1 : 0] i_ifu_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_ifu_pc,

    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_inst_type,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_inst_name,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_alu_type,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_alu_rs1,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_alu_rs2,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_jmp_type,
    input  logic                       i_idu_ctr_ram_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_ram_byt,
    input  logic                       i_idu_ctr_reg_wr_en,
    input  logic [`ARGS_WIDTH - 1 : 0] i_idu_ctr_reg_wr_src,
    output logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_inst_type,
    output logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_inst_name,
    output logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_alu_type,
    output logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_alu_rs1,
    output logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_alu_rs2,
    output logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_jmp_type,
    output logic                       o_idu_ctr_ram_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_ram_byt,
    output logic                       o_idu_ctr_reg_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_idu_ctr_reg_wr_src,

    input  logic [`DATA_WIDTH - 1 : 0] i_idu_rs1_data,
    input  logic [`DATA_WIDTH - 1 : 0] i_idu_rs2_data,
    output logic [`DATA_WIDTH - 1 : 0] o_idu_rs1_data,
    output logic [`DATA_WIDTH - 1 : 0] o_idu_rs2_data,

    input  logic [`DATA_WIDTH - 1 : 0] i_idu_jmp_or_reg_data
    output logic [`DATA_WIDTH - 1 : 0] o_idu_jmp_or_reg_data
);


    logic [`ADDR_WIDTH - 1 : 0] r_ifu_pc;

    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_inst_type;
    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_inst_name;
    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_alu_type;
    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_alu_rs1;
    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_alu_rs2;
    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_jmp_type;
    logic                       r_idu_ctr_ram_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_ram_byt;
    logic                       r_idu_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_reg_wr_src;

    logic [`DATA_WIDTH - 1 : 0] r_idu_rs1_data;
    logic [`DATA_WIDTH - 1 : 0] r_idu_rs2_data;

    logic [`DATA_WIDTH - 1 : 0] r_idu_jmp_or_reg_data;

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_ifu_pc <= `ADDR_INIT;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_ifu_pc <= i_ifu_pc;
        end
        else begin
            r_ifu_pc <= r_ifu_pc;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_idu_ctr_inst_type  = `INST_TYPE_X;
            r_idu_ctr_inst_name  = `INST_NAME_X;
            r_idu_ctr_alu_type   = `ALU_TYPE_X;
            r_idu_ctr_alu_rs1    = `ALU_RS1_X;
            r_idu_ctr_alu_rs2    = `ALU_RS2_X;
            r_idu_ctr_jmp_type   = `JMP_X;
            r_idu_ctr_ram_wr_en  = 1'b0;
            r_idu_ctr_ram_byt    = `RAM_BYT_X;
            r_idu_ctr_reg_wr_en  = 1'b0;
            r_idu_ctr_reg_wr_src = `REG_WR_SRC_X;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_idu_ctr_inst_type  = i_idu_ctr_inst_type;
            r_idu_ctr_inst_name  = i_idu_ctr_inst_name;
            r_idu_ctr_alu_type   = i_idu_ctr_alu_type;
            r_idu_ctr_alu_rs1    = i_idu_ctr_alu_rs1;
            r_idu_ctr_alu_rs2    = i_idu_ctr_alu_rs2;
            r_idu_ctr_jmp_type   = i_idu_ctr_jmp_type;
            r_idu_ctr_ram_wr_en  = i_idu_ctr_ram_wr_en;
            r_idu_ctr_ram_byt    = i_idu_ctr_ram_byt;
            r_idu_ctr_reg_wr_en  = i_idu_ctr_reg_wr_en;
            r_idu_ctr_reg_wr_src = i_idu_ctr_reg_wr_src;
        end
        else begin
            r_idu_ctr_inst_type  = r_idu_ctr_inst_type;
            r_idu_ctr_inst_name  = r_idu_ctr_inst_name;
            r_idu_ctr_alu_type   = r_idu_ctr_alu_type;
            r_idu_ctr_alu_rs1    = r_idu_ctr_alu_rs1;
            r_idu_ctr_alu_rs2    = r_idu_ctr_alu_rs2;
            r_idu_ctr_jmp_type   = r_idu_ctr_jmp_type;
            r_idu_ctr_ram_wr_en  = r_idu_ctr_ram_wr_en;
            r_idu_ctr_ram_byt    = r_idu_ctr_ram_byt;
            r_idu_ctr_reg_wr_en  = r_idu_ctr_reg_wr_en;
            r_idu_ctr_reg_wr_src = r_idu_ctr_reg_wr_src;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_idu_rs1_data <= `DATA_ZERO;
            r_idu_rs2_data <= `DATA_ZERO;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_idu_rs1_data <= i_idu_rs1_data;
            r_idu_rs2_data <= i_idu_rs2_data;
        end
        else begin
            r_idu_rs1_data <= r_idu_rs1_data;
            r_idu_rs2_data <= r_idu_rs2_data;
        end
    end

    always_ff @(posedge i_sys_clk) begin
        if (!i_sys_rst_n) begin
            r_idu_jmp_or_reg_data <= `DATA_ZERO;
        end
        else if (o_sys_valid && i_sys_ready) begin
            r_idu_jmp_or_reg_data <= i_idu_jmp_or_reg_data;
        end
        else begin
            r_idu_jmp_or_reg_data <= r_idu_jmp_or_reg_data;
        end
    end

    assign o_ifu_pc              = r_ifu_pc;
    assign o_idu_ctr_inst_type   = r_idu_ctr_inst_type;
    assign o_idu_ctr_inst_name   = r_idu_ctr_inst_name;
    assign o_idu_ctr_alu_type    = r_idu_ctr_alu_type;
    assign o_idu_ctr_alu_rs1     = r_idu_ctr_alu_rs1;
    assign o_idu_ctr_alu_rs2     = r_idu_ctr_alu_rs2;
    assign o_idu_ctr_jmp_type    = r_idu_ctr_jmp_type;
    assign o_idu_ctr_ram_wr_en   = r_idu_ctr_ram_wr_en;
    assign o_idu_ctr_ram_byt     = r_idu_ctr_ram_byt;
    assign o_idu_ctr_reg_wr_en   = r_idu_ctr_reg_wr_en;
    assign o_idu_ctr_reg_wr_src  = r_idu_ctr_reg_wr_src;
    assign o_idu_rs1_data        = r_idu_rs1_data;
    assign o_idu_rs2_data        = r_idu_rs2_data;
    assign o_idu_jmp_or_reg_data = r_idu_jmp_or_reg_data;

endmodule
