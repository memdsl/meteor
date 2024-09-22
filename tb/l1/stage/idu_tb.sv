`timescale 1ns / 1ps

`include "cfg.sv"

module idu_tb();

initial begin
    $dumpfile("build/idu_tb.vcd");
    $dumpvars(0, idu_tb);
end

parameter CYCLE      = 10;
parameter DATA_WIDTH = 32;

logic [`INST_WIDTH - 1 : 0] w_ram_inst;

initial begin
    // lui x1, 10
    w_ram_inst = 32'h0000_a0b7;
    #(CYCLE * 5);
    // auipc x1, 10
    w_ram_inst = 32'h0000_a097;
    #(CYCLE * 5);
    // jal x1, 10
    w_ram_inst = 32'h00a0_00ef;
    #(CYCLE * 5);
    // jalr x1, 10(x2)
    w_ram_inst = 32'h00a1_00e7;
    #(CYCLE * 5);
    // beq x1, x2, 10
    w_ram_inst = 32'h0020_8563;
    #(CYCLE * 5);
    // lb x1, 10(x2)
    w_ram_inst = 32'h00a1_0083;
    #(CYCLE * 5);
    // sb x1, offset(x2)
    w_ram_inst = 32'h0011_0023;
    #(CYCLE * 5);
    // addi x1, x2, 10
    w_ram_inst = 32'h00a1_0093;
    #(CYCLE * 5);
    // add x1, x2, x3
    w_ram_inst = 32'h0031_00b3;
    #(CYCLE * 5);
    // fence
    w_ram_inst = 32'h0ff0_000f;
    #(CYCLE * 5);
    // ecall
    w_ram_inst = 32'h0000_0073;
    #(CYCLE * 5);
    // ebreak
    w_ram_inst = 32'h0010_0073;
    #(CYCLE * 5);
    $finish;
end

idu #(
    .DATA_WIDTH(DATA_WIDTH)
) u_idu(
    .i_sys_ready          ( 1'h1),
    .o_sys_valid          (),
    .i_ram_inst           (w_ram_inst),
    .o_idu_ctr_alu_type   (),
    .o_idu_ctr_alu_rs1    (),
    .o_idu_ctr_alu_rs2    (),
    .o_idu_ctr_jmp_type   (),
    .o_idu_ctr_ram_wr_en  (),
    .o_idu_ctr_ram_byt    (),
    .o_idu_ctr_reg_wr_en  (),
    .o_idu_ctr_reg_wr_src (),
    .i_gpr_rs1_data       (32'h1),
    .i_gpr_rs2_data       (32'h2),
    .o_idu_gpr_rs1_id     (),
    .o_idu_gpr_rs2_id     (),
    .o_idu_gpr_rd_id      (),
    .i_ifu_pc             (32'h8000_0000),
    .o_idu_rs1_data       (),
    .o_idu_rs2_data       (),
    .o_idu_jmp_or_reg_data()
);

endmodule
