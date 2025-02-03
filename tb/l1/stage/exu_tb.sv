`timescale 1ns / 1ps

`include "cfg.sv"

module exu_tb();

parameter CYCLE      = 10;
parameter DATA_WIDTH = 32;

logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_alu_type;
logic [`ARGS_WIDTH - 1 : 0] r_idu_ctr_jmp_type;

initial begin
    r_idu_ctr_alu_type = `ALU_TYPE_SLL;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_SRL;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_SRA;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_ADD;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_SUB;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_XOR;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_OR;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_AND;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_SLT;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_SLTU;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_BEQ;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_BNE;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_BLT;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_BGE;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_BLTU;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_BGEU;
    #(CYCLE * 5);
    r_idu_ctr_alu_type = `ALU_TYPE_JALR;
    #(CYCLE * 5);

    r_idu_ctr_jmp_type = `JMP_J;
    #(CYCLE * 5);
    r_idu_ctr_jmp_type = `JMP_B;
    #(CYCLE * 5);
    r_idu_ctr_jmp_type = `JMP_E;
    #(CYCLE * 5);
    $finish;
end

exu #(
    .DATA_WIDTH(DATA_WIDTH)
) u_exu(
    .i_sys_ready          ( 1'h1),
    .o_sys_valid          (),
    .i_ifu_pc             (32'h8000_0000),
    .i_idu_ctr_alu_type   (r_idu_ctr_alu_type),
    .i_idu_rs1_data       (32'h1),
    .i_idu_rs2_data       (32'h2),
    .o_exu_res            (),
    .o_exu_zero           (),
    .o_exu_over           (),
    .o_exu_neg            (),
    .i_idu_ctr_jmp_type   (r_idu_ctr_jmp_type),
    .i_idu_jmp_or_reg_data(32'h3),
    .o_exu_jmp_en         (),
    .o_exu_jmp_pc         ()
);

endmodule
