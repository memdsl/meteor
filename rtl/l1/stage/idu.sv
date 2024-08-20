`define INST_WIDTH 32
`define DATA_WIDTH 32
`define ARGS_WIDTH 8
`define GPRS_WIDTH 5

module idu #(
    parameter DATA_WIDTH = 32
) (
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic                       i_ready,
    output logic                       o_valid,

    input  logic [`INST_WIDTH - 1 : 0] i_inst,

    output logic [`ARGS_WIDTH - 1 : 0] o_alu_type,
    output logic [`ARGS_WIDTH - 1 : 0] o_alu_rs1,
    output logic [`ARGS_WIDTH - 1 : 0] o_alu_rs2,
    output logic [`ARGS_WIDTH - 1 : 0] o_jmp_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_mem_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_mem_wr_byt,
    output logic [`ARGS_WIDTH - 1 : 0] o_reg_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_reg_wr_src,

    output logic [`GPRS_WIDTH - 1 : 0] o_rs1_id,
    output logic [`GPRS_WIDTH - 1 : 0] o_rs2_id,
    output logic [`GPRS_WIDTH - 1 : 0] o_rd_id,
    output logic [ DATA_WIDTH - 1 : 0] o_rs1_data,
    output logic [ DATA_WIDTH - 1 : 0] o_rs2_data
);



endmodule