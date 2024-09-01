`include "../../base/cfg.sv"

module cpu #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input logic i_sys_clk,
    input logic i_sys_rst_n
);

    // GPR wires


    // IFU wires
    logic                       w_exu_jmp_en;
    logic [`ADDR_WIDTH - 1 : 0] w_exu_jmp_pc;
    logic [`ADDR_WIDTH - 1 : 0] w_ifu_pc;
    logic [`ADDR_WIDTH - 1 : 0] w_ifu_pc_next;

    // IDU wires
    logic [`INST_WIDTH - 1 : 0] w_ram_inst;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_alu_type;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_alu_rs1;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_alu_rs2;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_jmp_type;
    logic                       w_ctr_ram_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_ram_wr_byt;
    logic                       w_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_reg_wr_src;
    logic [ DATA_WIDTH - 1 : 0] w_gpr_rs1_data;
    logic [ DATA_WIDTH - 1 : 0] w_gpr_rs2_data;
    logic [`GPRS_WIDTH - 1 : 0] w_gpr_rs1_id;
    logic [`GPRS_WIDTH - 1 : 0] w_gpr_rs2_id;
    logic [`GPRS_WIDTH - 1 : 0] w_gpr_rd_id;
    logic [ DATA_WIDTH - 1 : 0] w_alu_rs1_data;
    logic [ DATA_WIDTH - 1 : 0] w_alu_rs2_data;
    logic [ DATA_WIDTH - 1 : 0] w_idu_jmp_or_reg_data;

    gpr #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_gpr(
        .i_sys_clk        (i_sys_clk),
        .i_sys_rst_n      (i_sys_rst_n),
        .i_gpr_rd_rs1_id  (),
        .i_gpr_rd_rs2_id  (),
        .i_gpr_rd_end_id  (),
        .o_gpr_rd_rs1_data(),
        .o_gpr_rd_rs2_data(),
        .o_gpr_rd_end_data(),
        .i_gpr_wr_en      (),
        .i_gpr_wr_id      (),
        .i_gpr_wr_data    ()
    );

    ram #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_gpr(
        .i_sys_clk         (i_sys_clk),
        .i_sys_rst_n       (i_sys_rst_n),
        .i_ram_rd_inst_en  (),
        .i_ram_rd_inst_addr(),
        .o_ram_rd_inst_data(),
        .i_ram_rd_data_en  (),
        .i_ram_rd_data_addr(),
        .o_ram_rd_data_data(),
        .i_ram_wr_data_en  (),
        .i_ram_wr_data_addr(),
        .i_ram_wr_data_data(),
        .i_ram_wr_data_mask()
    );

    ifu u_ifu(
        .i_sys_clk    (i_sys_clk),
        .i_sys_rst_n  (i_sys_rst_n),
        .i_sys_ready  (1'h1),
        .o_sys_valid  (),
        .i_exu_jmp_en (w_exu_jmp_en),
        .i_exu_jmp_pc (w_exu_jmp_pc),
        .o_ifu_pc     (w_ifu_pc),
        .o_ifu_pc_next(w_ifu_pc_next)
    );

    idu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_idu(
        .i_sys_ready          (1'h1),
        .i_sys_valid          (),
        .i_ram_inst           (w_ram_inst),
        .o_ctr_alu_type       (w_ctr_alu_type),
        .o_ctr_alu_rs1        (w_ctr_alu_rs1),
        .o_ctr_alu_rs2        (w_ctr_alu_rs2),
        .o_ctr_jmp_type       (w_ctr_jmp_type),
        .o_ctr_ram_wr_en      (w_ctr_ram_wr_en),
        .o_ctr_ram_wr_byt     (w_ctr_ram_wr_byt),
        .o_ctr_reg_wr_en      (w_ctr_reg_wr_en),
        .o_ctr_reg_wr_src     (w_ctr_reg_wr_src),
        .i_gpr_rs1_data       (w_gpr_rs1_data),
        .i_gpr_rs2_data       (w_gpr_rs2_data),
        .o_gpr_rs1_id         (w_gpr_rs1_id),
        .o_gpr_rs2_id         (w_gpr_rs2_id),
        .o_gpr_rd_id          (w_gpr_rd_id),
        .i_ifu_pc             (w_ifu_pc),
        .o_alu_rs1_data       (w_alu_rs1_data),
        .o_alu_rs2_data       (w_alu_rs2_data),
        .o_idu_jmp_or_reg_data(w_idu_jmp_or_reg_data)
    );

    exu #() u_exu();

    lsu #() u_lsu();

    wbu #() u_wbu();

endmodule
