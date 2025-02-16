`timescale 1ns / 1ps

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

    output logic                           o_end_flag,
    output logic [`DATA_WIDTH     - 1 : 0] o_end_data
);

    assign o_rom_rd_en   = 1'b1;
    assign o_rom_rd_addr = w_ifu_pc;
    assign o_ram_rd_en   = w_lsu_ram_rd_en;
    assign o_ram_rd_addr = w_lsu_ram_rd_addr;
    assign o_ram_wr_en   = w_lsu_ram_wr_en;
    assign o_ram_wr_addr = w_lsu_ram_wr_addr;
    assign o_ram_wr_data = w_lsu_ram_wr_data;

    assign o_end_flag    = w_idu_end_flag;
    assign o_end_data    = w_gpr_end_data;

    // GPR
    logic [`DATA_WIDTH - 1 : 0] w_gpr_rs1_data;
    logic [`DATA_WIDTH - 1 : 0] w_gpr_rs2_data;
    logic [`DATA_WIDTH - 1 : 0] w_gpr_end_data;

    // IFU
    logic                       w_ifu_valid;
    logic                       w_ifu_ready;
    logic [`ADDR_WIDTH - 1 : 0] w_ifu_pc;

    // I2I
    logic                       w_i2i_valid;
    logic                       w_i2i_ready;
    logic [`ADDR_WIDTH - 1 : 0] w_i2i_pc;

    // IDU
    logic                       w_idu_valid;
    logic                       w_idu_ready;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_inst_type;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_inst_name;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_alu_type;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_alu_rs1;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_alu_rs2;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_jmp_type;
    logic                       w_idu_ctr_ram_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_ram_byt;
    logic                       w_idu_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_idu_ctr_reg_wr_src;
    logic [`GPRS_WIDTH - 1 : 0] w_idu_gpr_rs1_id;
    logic [`GPRS_WIDTH - 1 : 0] w_idu_gpr_rs2_id;
    logic [`GPRS_WIDTH - 1 : 0] w_idu_gpr_rd_id;
    logic [`ADDR_WIDTH - 1 : 0] w_idu_pc;
    logic [`DATA_WIDTH - 1 : 0] w_idu_rs1_data;
    logic [`DATA_WIDTH - 1 : 0] w_idu_rs2_data;
    logic [`DATA_WIDTH - 1 : 0] w_idu_jmp_or_reg_data;
    logic                       w_idu_end_flag;

    // IDU2EXU
    logic                       w_i2e_valid;
    logic                       w_i2e_ready;
    logic [`ADDR_WIDTH - 1 : 0] w_i2e_pc;
    logic [`ARGS_WIDTH - 1 : 0] w_i2e_ctr_inst_type;
    logic [`ARGS_WIDTH - 1 : 0] w_i2e_ctr_inst_name;
    logic [`ARGS_WIDTH - 1 : 0] w_i2e_ctr_alu_type;
    logic [`ARGS_WIDTH - 1 : 0] w_i2e_ctr_alu_rs1;
    logic [`ARGS_WIDTH - 1 : 0] w_i2e_ctr_alu_rs2;
    logic [`ARGS_WIDTH - 1 : 0] w_i2e_ctr_jmp_type;
    logic                       w_i2e_ctr_ram_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_i2e_ctr_ram_byt;
    logic                       w_i2e_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_i2e_ctr_reg_wr_src;
    logic [`DATA_WIDTH - 1 : 0] w_i2e_rs1_data;
    logic [`DATA_WIDTH - 1 : 0] w_i2e_rs2_data;
    logic [`GPRS_WIDTH - 1 : 0] w_i2e_gpr_rd_id;
    logic [`DATA_WIDTH - 1 : 0] w_i2e_jmp_or_reg_data;

    // EXU
    logic                       w_exu_valid;
    logic                       w_exu_ready;
    logic [`ADDR_WIDTH - 1 : 0] w_exu_pc;
    logic                       w_exu_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_exu_ctr_reg_wr_src;
    logic [`GPRS_WIDTH - 1 : 0] w_exu_gpr_rd_id;
    logic [`ARGS_WIDTH - 1 : 0] w_exu_ctr_inst_type;
    logic [`ARGS_WIDTH - 1 : 0] w_exu_ctr_ram_byt;
    logic                       w_exu_ctr_ram_wr_en;
    logic [`DATA_WIDTH - 1 : 0] w_exu_res;
    logic [`DATA_WIDTH - 1 : 0] w_exu_rs2_data;
    logic                       w_exu_jmp_en;
    logic [`ADDR_WIDTH - 1 : 0] w_exu_jmp_pc;
    logic                       w_exu_pc_en;

    // EXU2LSU
    logic                       w_e2l_valid;
    logic                       w_e2l_ready;
    logic [`ADDR_WIDTH - 1 : 0] w_e2l_pc;
    logic                       w_e2l_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_e2l_ctr_reg_wr_src;
    logic [`GPRS_WIDTH - 1 : 0] w_e2l_gpr_rd_id;
    logic [`ARGS_WIDTH - 1 : 0] w_e2l_ctr_inst_type;
    logic [`ARGS_WIDTH - 1 : 0] w_e2l_ctr_ram_byt;
    logic                       w_e2l_ctr_ram_wr_en;
    logic [`DATA_WIDTH - 1 : 0] w_e2l_res;
    logic [`DATA_WIDTH - 1 : 0] w_e2l_rs2_data;

    // LSU
    logic                           w_lsu_valid;
    logic                           w_lsu_ready;
    logic [`ADDR_WIDTH     - 1 : 0] w_lsu_pc;
    logic                           w_lsu_ctr_reg_wr_en;
    logic [`ARGS_WIDTH     - 1 : 0] w_lsu_ctr_reg_wr_src;
    logic [`GPRS_WIDTH     - 1 : 0] w_lsu_gpr_wr_id;
    logic [`DATA_WIDTH     - 1 : 0] w_lsu_alu_res;
    logic                           w_lsu_ram_rd_en;
    logic [`ADDR_WIDTH     - 1 : 0] w_lsu_ram_rd_addr;
    logic [`DATA_WIDTH     - 1 : 0] w_lsu_gpr_wr_data;
    logic [`DATA_WIDTH     - 1 : 0] w_lsu_ram_res;
    logic                           w_lsu_ram_wr_en;
    logic [`ADDR_WIDTH     - 1 : 0] w_lsu_ram_wr_addr;
    logic [`DATA_WIDTH     - 1 : 0] w_lsu_ram_wr_data;
    logic                           w_lsu_pc_en;

    // LSU2WBU
    logic                       w_l2w_valid;
    logic                       w_l2w_ready;
    logic                       w_l2w_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_l2w_ctr_reg_wr_src;
    logic [`ADDR_WIDTH - 1 : 0] w_l2w_pc;
    logic [`DATA_WIDTH - 1 : 0] w_l2w_alu_res;
    logic [`DATA_WIDTH - 1 : 0] w_l2w_ram_res;
    logic [`GPRS_WIDTH - 1 : 0] w_l2w_gpr_wr_id;

    // WBU
    logic                       w_wbu_valid;
    logic                       w_wbu_ready;
    logic                       w_wbu_gpr_wr_en;
    logic [`GPRS_WIDTH - 1 : 0] w_wbu_gpr_wr_id;
    logic [`DATA_WIDTH - 1 : 0] w_wbu_gpr_wr_data;
    logic                       w_wbu_pc_en;

    gpr u_gpr(
        .i_sys_clk        (i_sys_clk        ),
        .i_sys_rst_n      (i_sys_rst_n      ),
        .i_gpr_rd_rs1_id  (w_idu_gpr_rs1_id ),
        .i_gpr_rd_rs2_id  (w_idu_gpr_rs2_id ),
        .i_gpr_rd_end_id  (5'ha             ),
        .o_gpr_rd_rs1_data(w_gpr_rs1_data   ),
        .o_gpr_rd_rs2_data(w_gpr_rs2_data   ),
        .o_gpr_rd_end_data(w_gpr_end_data   ),
        .i_gpr_wr_en      (w_wbu_gpr_wr_en  ),
        .i_gpr_wr_id      (w_wbu_gpr_wr_id  ),
        .i_gpr_wr_data    (w_wbu_gpr_wr_data)
    );

    ifu u_ifu(
        .i_sys_clk    (i_sys_clk                              ),
        .i_sys_rst_n  (i_sys_rst_n                            ),
        .i_sys_pc_en  (w_exu_pc_en | w_lsu_pc_en),
        .i_wbu_valid  (w_wbu_valid                            ),
        .o_ifu_ready  (w_ifu_ready                            ),
        .i_i2i_ready  (w_i2i_ready                            ),
        .o_ifu_valid  (w_ifu_valid                            ),
        .i_exu_jmp_en (w_exu_jmp_en                           ),
        .i_exu_jmp_pc (w_exu_jmp_pc                           ),
        .o_ifu_pc     (w_ifu_pc                               ),
        .o_ifu_pc_next(                                       )
    );

    ifu2idu u_ifu2idu(
        .i_sys_clk  (i_sys_clk  ),
        .i_sys_rst_n(i_sys_rst_n),
        .i_ifu_valid(w_ifu_valid),
        .o_i2i_ready(w_i2i_ready),
        .i_idu_ready(w_idu_ready),
        .o_i2i_valid(w_i2i_valid),
        .i_ifu_pc   (w_ifu_pc   ),
        .o_i2i_pc   (w_i2i_pc   )
    );

    idu u_idu(
        .i_i2i_valid          (w_i2i_valid          ),
        .o_idu_ready          (w_idu_ready          ),
        .i_i2e_ready          (w_i2e_ready          ),
        .o_idu_valid          (w_idu_valid          ),
        .i_rom_inst           (i_rom_rd_data        ),
        .o_idu_ctr_inst_type  (w_idu_ctr_inst_type  ),
        .o_idu_ctr_inst_name  (w_idu_ctr_inst_name  ),
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
        .i_i2i_pc             (w_i2i_pc             ),
        .o_idu_pc             (w_idu_pc             ),
        .o_idu_rs1_data       (w_idu_rs1_data       ),
        .o_idu_rs2_data       (w_idu_rs2_data       ),
        .o_idu_jmp_or_reg_data(w_idu_jmp_or_reg_data),
        .o_idu_end_flag       (w_idu_end_flag       )
    );

    idu2exu u_idu2exu(
        .i_sys_clk            (i_sys_clk            ),
        .i_sys_rst_n          (i_sys_rst_n          ),
        .i_idu_valid          (w_idu_valid          ),
        .o_i2e_ready          (w_i2e_ready          ),
        .i_exu_ready          (w_exu_ready          ),
        .o_i2e_valid          (w_i2e_valid          ),
        .i_idu_pc             (w_idu_pc             ),
        .o_i2e_pc             (w_i2e_pc             ),
        .i_idu_ctr_inst_type  (w_idu_ctr_inst_type  ),
        .i_idu_ctr_inst_name  (w_idu_ctr_inst_name  ),
        .i_idu_ctr_alu_type   (w_idu_ctr_alu_type   ),
        .i_idu_ctr_alu_rs1    (w_idu_ctr_alu_rs1    ),
        .i_idu_ctr_alu_rs2    (w_idu_ctr_alu_rs2    ),
        .i_idu_ctr_jmp_type   (w_idu_ctr_jmp_type   ),
        .i_idu_ctr_ram_wr_en  (w_idu_ctr_ram_wr_en  ),
        .i_idu_ctr_ram_byt    (w_idu_ctr_ram_byt    ),
        .i_idu_ctr_reg_wr_en  (w_idu_ctr_reg_wr_en  ),
        .i_idu_ctr_reg_wr_src (w_idu_ctr_reg_wr_src ),
        .o_i2e_ctr_inst_type  (w_i2e_ctr_inst_type  ),
        .o_i2e_ctr_inst_name  (w_i2e_ctr_inst_name  ),
        .o_i2e_ctr_alu_type   (w_i2e_ctr_alu_type   ),
        .o_i2e_ctr_alu_rs1    (w_i2e_ctr_alu_rs1    ),
        .o_i2e_ctr_alu_rs2    (w_i2e_ctr_alu_rs2    ),
        .o_i2e_ctr_jmp_type   (w_i2e_ctr_jmp_type   ),
        .o_i2e_ctr_ram_wr_en  (w_i2e_ctr_ram_wr_en  ),
        .o_i2e_ctr_ram_byt    (w_i2e_ctr_ram_byt    ),
        .o_i2e_ctr_reg_wr_en  (w_i2e_ctr_reg_wr_en  ),
        .o_i2e_ctr_reg_wr_src (w_i2e_ctr_reg_wr_src ),
        .i_idu_rs1_data       (w_idu_rs1_data       ),
        .i_idu_rs2_data       (w_idu_rs2_data       ),
        .o_i2e_rs1_data       (w_i2e_rs1_data       ),
        .o_i2e_rs2_data       (w_i2e_rs2_data       ),
        .i_idu_gpr_rd_id      (w_idu_gpr_rd_id      ),
        .o_i2e_gpr_rd_id      (w_i2e_gpr_rd_id      ),
        .i_idu_jmp_or_reg_data(w_idu_jmp_or_reg_data),
        .o_i2e_jmp_or_reg_data(w_i2e_jmp_or_reg_data)
    );

    exu u_exu(
        .i_i2e_valid          (w_i2e_valid          ),
        .o_exu_ready          (w_exu_ready          ),
        .i_e2l_ready          (w_e2l_ready          ),
        .o_exu_valid          (w_exu_valid          ),
        .i_i2e_pc             (w_i2e_pc             ),
        .o_exu_pc             (w_exu_pc             ),
        .i_i2e_ctr_reg_wr_en  (w_i2e_ctr_reg_wr_en  ),
        .i_i2e_ctr_reg_wr_src (w_i2e_ctr_reg_wr_src ),
        .i_i2e_gpr_rd_id      (w_i2e_gpr_rd_id      ),
        .o_exu_ctr_reg_wr_en  (w_exu_ctr_reg_wr_en  ),
        .o_exu_ctr_reg_wr_src (w_exu_ctr_reg_wr_src ),
        .o_exu_gpr_rd_id      (w_exu_gpr_rd_id      ),
        .i_i2e_ctr_inst_type  (w_i2e_ctr_inst_type  ),
        .i_i2e_ctr_ram_byt    (w_i2e_ctr_ram_byt    ),
        .i_i2e_ctr_ram_wr_en  (w_i2e_ctr_ram_wr_en  ),
        .o_exu_ctr_inst_type  (w_exu_ctr_inst_type  ),
        .o_exu_ctr_ram_byt    (w_exu_ctr_ram_byt    ),
        .o_exu_ctr_ram_wr_en  (w_exu_ctr_ram_wr_en  ),
        .i_i2e_ctr_alu_type   (w_i2e_ctr_alu_type   ),
        .i_i2e_rs1_data       (w_i2e_rs1_data       ),
        .i_i2e_rs2_data       (w_i2e_rs2_data       ),
        .o_exu_res            (w_exu_res            ),
        .o_exu_rs2_data       (w_exu_rs2_data       ),
        .i_i2e_ctr_jmp_type   (w_i2e_ctr_jmp_type   ),
        .i_i2e_jmp_or_reg_data(w_i2e_jmp_or_reg_data),
        .o_exu_jmp_en         (w_exu_jmp_en         ),
        .o_exu_jmp_pc         (w_exu_jmp_pc         ),
        .o_exu_pc_en          (w_exu_pc_en          )
    );

    exu2lsu u_exu2lsu(
        .i_sys_clk           (i_sys_clk           ),
        .i_sys_rst_n         (i_sys_rst_n         ),
        .i_exu_valid         (w_exu_valid         ),
        .o_e2l_ready         (w_e2l_ready         ),
        .i_lsu_ready         (w_lsu_ready         ),
        .o_e2l_valid         (w_e2l_valid         ),
        .i_exu_pc            (w_exu_pc            ),
        .o_e2l_pc            (w_e2l_pc            ),
        .i_exu_ctr_reg_wr_en (w_exu_ctr_reg_wr_en ),
        .i_exu_ctr_reg_wr_src(w_exu_ctr_reg_wr_src),
        .i_exu_gpr_rd_id     (w_exu_gpr_rd_id     ),
        .o_e2l_ctr_reg_wr_en (w_e2l_ctr_reg_wr_en ),
        .o_e2l_ctr_reg_wr_src(w_e2l_ctr_reg_wr_src),
        .o_e2l_gpr_rd_id     (w_e2l_gpr_rd_id     ),
        .i_exu_ctr_inst_type (w_exu_ctr_inst_type ),
        .i_exu_ctr_ram_byt   (w_exu_ctr_ram_byt   ),
        .i_exu_ctr_ram_wr_en (w_exu_ctr_ram_wr_en ),
        .o_e2l_ctr_inst_type (w_e2l_ctr_inst_type ),
        .o_e2l_ctr_ram_byt   (w_e2l_ctr_ram_byt   ),
        .o_e2l_ctr_ram_wr_en (w_e2l_ctr_ram_wr_en ),
        .i_exu_res           (w_exu_res           ),
        .i_exu_rs2_data      (w_exu_rs2_data      ),
        .o_e2l_res           (w_e2l_res           ),
        .o_e2l_rs2_data      (w_e2l_rs2_data      )
    );

    lsu u_lsu(
        .i_e2l_valid         (w_e2l_valid         ),
        .o_lsu_ready         (w_lsu_ready         ),
        .i_l2w_ready         (w_l2w_ready         ),
        .o_lsu_valid         (w_lsu_valid         ),
        .i_e2l_pc            (w_e2l_pc            ),
        .o_lsu_pc            (w_lsu_pc            ),
        .i_e2l_ctr_reg_wr_en (w_e2l_ctr_reg_wr_en ),
        .i_e2l_ctr_reg_wr_src(w_e2l_ctr_reg_wr_src),
        .i_e2l_gpr_wr_id     (w_e2l_gpr_rd_id     ),
        .o_lsu_ctr_reg_wr_en (w_lsu_ctr_reg_wr_en ),
        .o_lsu_ctr_reg_wr_src(w_lsu_ctr_reg_wr_src),
        .o_lsu_gpr_wr_id     (w_lsu_gpr_wr_id     ),
        .i_e2l_ctr_ram_byt   (w_e2l_ctr_ram_byt   ),
        .i_e2l_res           (w_e2l_res           ),
        .o_lsu_alu_res       (w_lsu_alu_res       ),
        .i_ram_rd_data       (i_ram_rd_data       ),
        .o_lsu_ram_rd_en     (w_lsu_ram_rd_en     ),
        .o_lsu_ram_rd_addr   (w_lsu_ram_rd_addr   ),
        .o_lsu_gpr_wr_data   (w_lsu_gpr_wr_data   ),
        .o_lsu_ram_res       (w_lsu_ram_res       ),
        .i_e2l_ctr_ram_wr_en (w_e2l_ctr_ram_wr_en ),
        .i_e2l_rs2_data      (w_e2l_rs2_data      ),
        .o_lsu_ram_wr_en     (w_lsu_ram_wr_en     ),
        .o_lsu_ram_wr_addr   (w_lsu_ram_wr_addr   ),
        .o_lsu_ram_wr_data   (w_lsu_ram_wr_data   ),
        .i_e2l_ctr_inst_type (w_e2l_ctr_inst_type ),
        .o_lsu_pc_en         (w_lsu_pc_en         )
    );

    lsu2wbu u_lsu2wbu(
        .i_sys_clk           (i_sys_clk           ),
        .i_sys_rst_n         (i_sys_rst_n         ),
        .i_lsu_valid         (w_lsu_valid         ),
        .o_l2w_ready         (w_l2w_ready         ),
        .i_wbu_ready         (w_wbu_ready         ),
        .o_l2w_valid         (w_l2w_valid         ),
        .i_lsu_ctr_reg_wr_en (w_lsu_ctr_reg_wr_en ),
        .i_lsu_ctr_reg_wr_src(w_lsu_ctr_reg_wr_src),
        .i_lsu_pc            (w_lsu_pc            ),
        .i_lsu_alu_res       (w_lsu_alu_res       ),
        .i_lsu_ram_res       (w_lsu_ram_res       ),
        .i_lsu_gpr_wr_id     (w_lsu_gpr_wr_id     ),
        .o_l2w_ctr_reg_wr_en (w_l2w_ctr_reg_wr_en ),
        .o_l2w_ctr_reg_wr_src(w_l2w_ctr_reg_wr_src),
        .o_l2w_pc            (w_l2w_pc            ),
        .o_l2w_alu_res       (w_l2w_alu_res       ),
        .o_l2w_ram_res       (w_l2w_ram_res       ),
        .o_l2w_gpr_wr_id     (w_l2w_gpr_wr_id     )
    );

    wbu u_wbu(
        .i_l2w_valid         (w_l2w_valid         ),
        .o_wbu_ready         (w_wbu_ready         ),
        .i_ifu_ready         (w_ifu_ready         ),
        .o_wbu_valid         (w_wbu_valid         ),
        .i_l2w_ctr_reg_wr_en (w_l2w_ctr_reg_wr_en ),
        .i_l2w_ctr_reg_wr_src(w_l2w_ctr_reg_wr_src),
        .i_l2w_pc            (w_l2w_pc            ),
        .i_l2w_alu_res       (w_l2w_alu_res       ),
        .i_l2w_ram_res       (w_l2w_ram_res       ),
        .i_l2w_gpr_wr_id     (w_l2w_gpr_wr_id     ),
        .o_wbu_gpr_wr_en     (w_wbu_gpr_wr_en     ),
        .o_wbu_gpr_wr_id     (w_wbu_gpr_wr_id     ),
        .o_wbu_gpr_wr_data   (w_wbu_gpr_wr_data   ),
        .o_wbu_pc_en         (w_wbu_pc_en         )
    );

endmodule
