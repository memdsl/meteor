`timescale 1ns / 1ps

`include "cfg.sv"

module cpu(
    input  logic                           i_sys_clk,
    input  logic                           i_sys_rst_n,

    input  logic [`INST_WIDTH     - 1 : 0] i_rom_rd_data,
    output logic                           o_rom_rd_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_rom_rd_addr,

    input  logic [`DATA_WIDTH     - 1 : 0] i_ram_rd_data,
    output logic                           o_ram_rd_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_ram_rd_addr,
    output logic                           o_ram_wr_en,
    output logic [`ADDR_WIDTH     - 1 : 0] o_ram_wr_addr,
    output logic [`DATA_WIDTH     - 1 : 0] o_ram_wr_data,
    output logic [`DATA_WIDTH / 8 - 1 : 0] o_ram_wr_mask
);

    // IFU
    logic                       w_exu_jmp_en;
    logic [`ADDR_WIDTH - 1 : 0] w_exu_jmp_pc;
    logic [`ADDR_WIDTH - 1 : 0] w_ifu_pc;
    logic [`ADDR_WIDTH - 1 : 0] w_ifu_pc_next;

    // IDU
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_alu_type;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_alu_rs1;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_alu_rs2;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_jmp_type;
    logic                       w_idu_ctr_ram_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_ram_byt;
    logic                       w_idu_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_reg_wr_src;
    logic [`DATA_WIDTH - 1 : 0] w_gpr_rs1_data;
    logic [`DATA_WIDTH - 1 : 0] w_gpr_rs2_data;
    logic [`GPRS_WIDTH - 1 : 0] w_idu_gpr_rs1_id;
    logic [`GPRS_WIDTH - 1 : 0] w_idu_gpr_rs2_id;
    logic [`GPRS_WIDTH - 1 : 0] w_idu_gpr_rd_id;
    logic [`DATA_WIDTH - 1 : 0] w_idu_rs1_data;
    logic [`DATA_WIDTH - 1 : 0] w_idu_rs2_data;
    logic [`DATA_WIDTH - 1 : 0] w_idu_jmp_or_reg_data;

    // EXU
    logic [`DATA_WIDTH - 1 : 0] w_exu_res;
    logic                       w_exu_zero;
    logic                       w_exu_over;
    logic                       w_exu_neg;

    // LSU
    logic                           w_lsu_ram_rd_en;
    logic [`ADDR_WIDTH     - 1 : 0] w_lsu_ram_rd_addr;
    logic [`DATA_WIDTH     - 1 : 0] w_lsu_gpr_wr_data;
    logic                           w_lsu_ram_wr_en;
    logic [`ADDR_WIDTH     - 1 : 0] w_lsu_ram_wr_addr;
    logic [`DATA_WIDTH     - 1 : 0] w_lsu_ram_wr_data;
    logic [`DATA_WIDTH / 8 - 1 : 0] w_lsu_ram_wr_mask;

    // WBU
    logic [`GPRS_WIDTH - 1 : 0] w_gpr_wr_id;
    logic                       w_wbu_gpr_wr_en;
    logic [`GPRS_WIDTH - 1 : 0] w_wbu_gpr_wr_id;
    logic [`DATA_WIDTH - 1 : 0] w_wbu_gpr_wr_data;

    assign o_rom_rd_en   = 1'b1;
    assign o_rom_rd_addr = w_ifu_pc;
    assign o_ram_rd_en   = w_lsu_ram_rd_en;
    assign o_ram_rd_addr = w_lsu_ram_rd_addr;
    assign o_ram_wr_en   = w_lsu_ram_wr_en;
    assign o_ram_wr_addr = w_lsu_ram_wr_addr;
    assign o_ram_wr_data = w_lsu_ram_wr_data;
    assign o_ram_wr_mask = w_lsu_ram_wr_mask;

    gpr u_gpr(
        .i_sys_clk        (i_sys_clk        ),
        .i_sys_rst_n      (i_sys_rst_n      ),
        .i_gpr_rd_rs1_id  (w_idu_gpr_rs1_id ),
        .i_gpr_rd_rs2_id  (w_idu_gpr_rs2_id ),
        .i_gpr_rd_end_id  (5'ha             ),
        .o_gpr_rd_rs1_data(w_gpr_rs1_data   ),
        .o_gpr_rd_rs2_data(w_gpr_rs2_data   ),
        .o_gpr_rd_end_data(                 ),
        .i_gpr_wr_en      (w_wbu_gpr_wr_en  ),
        .i_gpr_wr_id      (w_wbu_gpr_wr_id  ),
        .i_gpr_wr_data    (w_wbu_gpr_wr_data)
    );

    ifu u_ifu(
        .i_sys_clk    (i_sys_clk    ),
        .i_sys_rst_n  (i_sys_rst_n  ),
        .i_sys_ready  (1'h1         ),
        .o_sys_valid  (             ),
        .i_exu_jmp_en (w_exu_jmp_en ),
        .i_exu_jmp_pc (w_exu_jmp_pc ),
        .o_ifu_pc     (w_ifu_pc     ),
        .o_ifu_pc_next(w_ifu_pc_next)
    );

    idu u_idu(
        .i_sys_ready          (1'h1                 ),
        .o_sys_valid          (                     ),
        .i_ram_inst           (i_rom_rd_data        ),
        .o_idu_ctr_alu_type   (w_idu_ctr_alu_type   ),
        .o_idu_ctr_alu_rs1    (w_idu_ctr_alu_rs1    ),
        .o_idu_ctr_alu_rs2    (w_idu_ctr_alu_rs2    ),
        .o_idu_ctr_jmp_type   (w_idu_ctr_jmp_type   ),
        .o_idu_ctr_ram_wr_en  (w_idu_ctr_ram_wr_en  ),
        .o_idu_ctr_ram_byt    (w_idu_ctr_ram_byt    ),
        .o_idu_ctr_reg_wr_en  (w_idu_ctr_reg_wr_en  ),
        .o_idu_ctr_reg_wr_src (w_idu_ctr_reg_wr_src ),
        .i_gpr_rs1_data       (w_gpr_rs1_data       ),
        .i_gpr_rs2_data       (w_gpr_rs2_data       ),
        .o_idu_gpr_rs1_id     (w_idu_gpr_rs1_id     ),
        .o_idu_gpr_rs2_id     (w_idu_gpr_rs2_id     ),
        .o_idu_gpr_rd_id      (w_idu_gpr_rd_id      ),
        .i_ifu_pc             (w_ifu_pc             ),
        .o_idu_rs1_data       (w_idu_rs1_data       ),
        .o_idu_rs2_data       (w_idu_rs2_data       ),
        .o_idu_jmp_or_reg_data(w_idu_jmp_or_reg_data)
    );

    exu u_exu(
        .i_sys_ready          (1'h1                 ),
        .o_sys_valid          (                     ),
        .i_ifu_pc             (w_ifu_pc             ),
        .i_idu_ctr_alu_type   (w_idu_ctr_alu_type   ),
        .i_idu_rs1_data       (w_idu_rs1_data       ),
        .i_idu_rs2_data       (w_idu_rs2_data       ),
        .o_exu_res            (w_exu_res            ),
        .o_exu_zero           (w_exu_zero           ),
        .o_exu_over           (w_exu_over           ),
        .o_exu_neg            (w_exu_neg            ),
        .i_idu_ctr_jmp_type   (w_idu_ctr_jmp_type   ),
        .i_idu_jmp_or_reg_data(w_idu_jmp_or_reg_data),
        .o_exu_jmp_en         (w_exu_jmp_en         ),
        .o_exu_jmp_pc         (w_exu_jmp_pc         )
    );

    lsu u_lsu(
        .i_sys_ready        (1'h1               ),
        .o_sys_valid        (                   ),
        .i_idu_ctr_ram_byt  (w_idu_ctr_ram_byt  ),
        .i_exu_res          (w_exu_res          ),
        .i_ram_rd_data      (i_ram_rd_data      ),
        .o_lsu_ram_rd_en    (w_lsu_ram_rd_en    ),
        .o_lsu_ram_rd_addr  (w_lsu_ram_rd_addr  ),
        .o_lsu_gpr_wr_data  (w_lsu_gpr_wr_data  ),
        .i_idu_ctr_ram_wr_en(w_idu_ctr_ram_wr_en),
        .i_gpr_rs2_data     (w_gpr_rs2_data     ),
        .o_lsu_ram_wr_en    (w_lsu_ram_wr_en    ),
        .o_lsu_ram_wr_addr  (w_lsu_ram_wr_addr  ),
        .o_lsu_ram_wr_data  (w_lsu_ram_wr_data  ),
        .o_lsu_ram_wr_mask  (w_lsu_ram_wr_mask  )
    );

    wbu u_wbu(
        .i_sys_ready         (1'h1                ),
        .o_sys_valid         (                    ),
        .i_idu_ctr_reg_wr_en (w_idu_ctr_reg_wr_en ),
        .i_idu_ctr_reg_wr_src(w_idu_ctr_reg_wr_src),
        .i_ifu_pc            (w_ifu_pc            ),
        .i_exu_res           (w_exu_res           ),
        .i_lsu_res           (w_lsu_gpr_wr_data   ),
        .i_gpr_wr_id         (w_gpr_wr_id         ),
        .o_wbu_gpr_wr_en     (w_wbu_gpr_wr_en     ),
        .o_wbu_gpr_wr_id     (w_wbu_gpr_wr_id     ),
        .o_wbu_gpr_wr_data   (w_wbu_gpr_wr_data   )
    );

endmodule
