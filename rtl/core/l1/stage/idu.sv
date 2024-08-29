`define INST_WIDTH 32
`define ADDR_WIDTH 32
`define DATA_WIDTH 32

`define ARGS_WIDTH 8
`define GPRS_WIDTH 5

`define ALU_TYPE_X     0
`define ALU_TYPE_ADD   1
`define ALU_TYPE_JALR  2
`define ALU_TYPE_BEQ   3
`define ALU_TYPE_BNE   4
`define ALU_TYPE_BLT   5
`define ALU_TYPE_BGE   6
`define ALU_TYPE_BLTU  7
`define ALU_TYPE_BGEU  8
`define ALU_TYPE_SLT   9
`define ALU_TYPE_SLTU 10
`define ALU_TYPE_XOR  11
`define ALU_TYPE_OR   12
`define ALU_TYPE_AND  13
`define ALU_TYPE_SLL  14
`define ALU_TYPE_SRL  15
`define ALU_TYPE_SRA  16
`define ALU_TYPE_SUB  17

`define ALU_RS1_X       0
`define ALU_RS1_GPR     1
`define ALU_RS1_PC      2

`define ALU_RS2_X       0
`define ALU_RS2_GPR     1
`define ALU_RS2_IMM_I   2
`define ALU_RS2_IMM_S   3
`define ALU_RS2_IMM_B   4
`define ALU_RS2_IMM_U   5
`define ALU_RS2_IMM_J   6

`define MEM_BYT_X       0
`define MEM_BYT_1_U     1
`define MEM_BYT_2_U     2
`define MEM_BYT_4_U     3
`define MEM_BYT_8_U     4
`define MEM_BYT_1_S     5
`define MEM_BYT_2_S     6
`define MEM_BYT_4_S     7
`define MEM_BYT_8_S     8

`define REG_WR_SRC_X    0
`define REG_WR_SRC_ALU  1
`define REG_WR_SRC_MEM  2
`define REG_WR_SRC_PC   3
`define REG_WR_SRC_CSR  4

module idu #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic                       i_ready,
    output logic                       o_valid,

    input  logic [`ADDR_WIDTH - 1 : 0] i_pc,
    input  logic [`INST_WIDTH - 1 : 0] i_inst,

    output logic [`ARGS_WIDTH - 1 : 0] o_alu_type,
    output logic [`ARGS_WIDTH - 1 : 0] o_alu_rs1,
    output logic [`ARGS_WIDTH - 1 : 0] o_alu_rs2,
    output logic                       o_jmp_en,
    output logic                       o_mem_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_mem_wr_byt,
    output logic                       o_reg_wr_en,
    output logic [`ARGS_WIDTH - 1 : 0] o_reg_wr_src,

    input  logic [ DATA_WIDTH - 1 : 0] i_gpr_rs1_data,
    input  logic [ DATA_WIDTH - 1 : 0] i_gpr_rs2_data,
    output logic [`GPRS_WIDTH - 1 : 0] o_gpr_rs1_id,
    output logic [`GPRS_WIDTH - 1 : 0] o_gpr_rs2_id,
    output logic [`GPRS_WIDTH - 1 : 0] o_gpr_rd_id,

    output logic [ DATA_WIDTH - 1 : 0] o_rs1_data,
    output logic [ DATA_WIDTH - 1 : 0] o_rs2_data
);

    assign o_valid = 1'h1;

    logic [6 : 0]               w_inst_opcode;
    logic [2 : 0]               w_inst_funct3;
    logic [6 : 0]               w_inst_funct7;
    logic [`GPRS_WIDTH - 1 : 0] w_inst_rs1_id;
    logic [`GPRS_WIDTH - 1 : 0] w_inst_rs2_id;
    logic [`GPRS_WIDTH - 1 : 0] w_inst_rd_id;
    logic [ DATA_WIDTH - 1 : 0] w_inst_imm;

    assign w_inst_opcode = i_inst[ 6 :  0];
    assign w_inst_funct3 = i_inst[14 : 12];
    assign w_inst_funct7 = i_inst[31 : 25];
    assign w_inst_rs1_id = i_inst[19 : 15];
    assign w_inst_rs2_id = i_inst[24 : 20];
    assign w_inst_rd_id  = i_inst[11 :  7];

    imm #(
        .DATA_WIDTH(DATA_WIDTH)
    ) imm_inst(
        .i_inst       (i_inst),
        .i_inst_opcode(w_inst_opcode),
        .o_inst_imm   (w_inst_imm)
    );

    logic [`ARGS_WIDTH - 1 : 0] w_alu_type;
    logic [`ARGS_WIDTH - 1 : 0] w_alu_rs1;
    logic [`ARGS_WIDTH - 1 : 0] w_alu_rs2;
    logic                       w_jmp_en;
    logic                       w_mem_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_mem_byt;
    logic                       w_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_reg_wr_src;

    always_comb begin
        case (w_inst_opcode)
            // LUI
            7'b0110111: begin
                w_alu_type   = `ALU_TYPE_ADD;
                w_alu_rs1    = `ALU_RS1_X;
                w_alu_rs2    = `ALU_RS2_IMM_U;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h0;
                w_reg_wr_src = `REG_WR_SRC_X;
            end
            // AUIPC
            7'b0010111: begin
                w_alu_type   = `ALU_TYPE_ADD;
                w_alu_rs1    = `ALU_RS1_PC;
                w_alu_rs2    = `ALU_RS2_IMM_U;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h0;
                w_reg_wr_src = `REG_WR_SRC_X;
            end
            // JAL
            7'b1101111: begin
                w_alu_type   = `ALU_TYPE_ADD;
                w_alu_rs1    = `ALU_RS1_PC;
                w_alu_rs2    = `ALU_RS2_IMM_J;
                w_jmp_en     = 1'h1;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h1;
                w_reg_wr_src = `REG_WR_SRC_PC;
            end
            // JALR
            7'b1100111: begin
                w_alu_type   = `ALU_TYPE_JALR;
                w_alu_rs1    = `ALU_RS1_GPR;
                w_alu_rs2    = `ALU_RS2_IMM_I;
                w_jmp_en     = 1'h1;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h1;
                w_reg_wr_src = `REG_WR_SRC_PC;
            end
            // BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                w_alu_type   = (w_inst_funct3 === 3'b000) ? `ALU_TYPE_BEQ  :
                               (w_inst_funct3 === 3'b001) ? `ALU_TYPE_BNE  :
                               (w_inst_funct3 === 3'b100) ? `ALU_TYPE_BLT  :
                               (w_inst_funct3 === 3'b101) ? `ALU_TYPE_BGE  :
                               (w_inst_funct3 === 3'b110) ? `ALU_TYPE_BLTU :
                               (w_inst_funct3 === 3'b111) ? `ALU_TYPE_BGEU :
                                                            `ALU_TYPE_X;
                w_alu_rs1    = `ALU_RS1_GPR;
                w_alu_rs2    = `ALU_RS2_GPR;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h0;
                w_reg_wr_src = `REG_WR_SRC_X;
            end
            // LB, LH, LW, LBU, LHU
            7'b0000011: begin
                w_alu_type   = `ALU_TYPE_ADD;
                w_alu_rs1    = `ALU_RS1_GPR;
                w_alu_rs2    = `ALU_RS2_IMM_I;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = (w_inst_funct3 === 3'b000) ? `MEM_BYT_1_S :
                               (w_inst_funct3 === 3'b001) ? `MEM_BYT_2_S :
                               (w_inst_funct3 === 3'b010) ? `MEM_BYT_4_S :
                               (w_inst_funct3 === 3'b100) ? `MEM_BYT_1_U :
                               (w_inst_funct3 === 3'b101) ? `MEM_BYT_2_U :
                                                            `MEM_BYT_X;
                w_reg_wr_en  = 1'h1;
                w_reg_wr_src = `REG_WR_SRC_MEM;
            end
            // SB, SH, SW
            7'b0100011: begin
                w_alu_type   = `ALU_TYPE_ADD;
                w_alu_rs1    = `ALU_RS1_GPR;
                w_alu_rs2    = `ALU_RS2_IMM_S;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h1;
                w_mem_byt    = (w_inst_funct3 === 3'b000) ? `MEM_BYT_1_U :
                               (w_inst_funct3 === 3'b001) ? `MEM_BYT_2_U :
                               (w_inst_funct3 === 3'b010) ? `MEM_BYT_4_U :
                                                            `MEM_BYT_X;
                w_reg_wr_en  = 1'h0;
                w_reg_wr_src = `REG_WR_SRC_X;
            end
            // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            7'b0010011: begin
                w_alu_type   = (w_inst_funct3 === 3'b000    ) ? `ALU_TYPE_ADD  :
                               (w_inst_funct3 === 3'b010    ) ? `ALU_TYPE_SLT  :
                               (w_inst_funct3 === 3'b011    ) ? `ALU_TYPE_SLTU :
                               (w_inst_funct3 === 3'b100    ) ? `ALU_TYPE_XOR  :
                               (w_inst_funct3 === 3'b110    ) ? `ALU_TYPE_OR   :
                               (w_inst_funct3 === 3'b111    ) ? `ALU_TYPE_AND  :
                               (w_inst_funct3 === 3'b001    ) ? `ALU_TYPE_SLL  :
                               (w_inst_funct3 === 3'b101    ) ?
                              ((w_inst_funct7 === 7'b0000000) ? `ALU_TYPE_SRL  :
                                                                `ALU_TYPE_SRA) :
                                                                `ALU_TYPE_X;
                w_alu_rs1    = `ALU_RS1_GPR;
                w_alu_rs2    = `ALU_RS2_IMM_I;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h1;
                w_reg_wr_src = `REG_WR_SRC_ALU;
            end
            // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            7'b0110011: begin
                w_alu_type   = (w_inst_funct3 === 3'b000    ) ?
                              ((w_inst_funct7 === 7'b0000000) ? `ALU_TYPE_ADD  :
                                                                `ALU_TYPE_SUB) :
                               (w_inst_funct3 === 3'b001    ) ? `ALU_TYPE_SLL  :
                               (w_inst_funct3 === 3'b010    ) ? `ALU_TYPE_SLT  :
                               (w_inst_funct3 === 3'b011    ) ? `ALU_TYPE_SLTU :
                               (w_inst_funct3 === 3'b100    ) ? `ALU_TYPE_XOR  :
                               (w_inst_funct3 === 3'b101    ) ?
                              ((w_inst_funct7 === 7'b0000000) : `ALU_TYPE_SRL  :
                                                                `ALU_TYPE_SRA) :
                               (w_inst_funct3 === 3'b110    ) ? `ALU_TYPE_OR   :
                               (w_inst_funct3 === 3'b111    ) ? `ALU_TYPE_AND  :
                                                                `ALU_TYPE_X;
                w_alu_rs1    = `ALU_RS1_GPR;
                w_alu_rs2    = `ALU_RS2_GPR;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h1;
                w_reg_wr_src = `REG_WR_SRC_ALU;
            end
            // FENCE
            7'b0001111: begin
                w_alu_type   = `ALU_TYPE_X;
                w_alu_rs1    = `ALU_RS1_X;
                w_alu_rs2    = `ALU_RS2_X;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h0;
                w_reg_wr_src = `REG_WR_SRC_X;
            end
            // ECALL, EBREAK
            7'b1110011: begin
                w_alu_type   = `ALU_TYPE_X;
                w_alu_rs1    = `ALU_RS1_X;
                w_alu_rs2    = `ALU_RS2_X;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h0;
                w_reg_wr_src = `REG_WR_SRC_X;
            end
            default: begin
                w_alu_type   = `ALU_TYPE_X;
                w_alu_rs1    = `ALU_RS1_X;
                w_alu_rs2    = `ALU_RS2_X;
                w_jmp_en     = 1'h0;
                w_mem_wr_en  = 1'h0;
                w_mem_byt    = `MEM_BYT_X;
                w_reg_wr_en  = 1'h0;
                w_reg_wr_src = `REG_WR_SRC_X;
            end
        endcase
    end

    assign o_alu_type   = (o_valid && i_ready) ? w_alu_type   : `ALU_TYPE_X;
    assign o_alu_rs1    = (o_valid && i_ready) ? w_alu_rs1    : `ALU_RS1_X;
    assign o_alu_rs2    = (o_valid && i_ready) ? w_alu_rs2    : `ALU_RS2_X;
    assign o_jmp_en     = (o_valid && i_ready) ? w_jmp_en     : 1'h0;
    assign o_mem_wr_en  = (o_valid && i_ready) ? w_mem_wr_en  : 1'h0;
    assign o_mem_wr_byt = (o_valid && i_ready) ? w_mem_byt    : `MEM_BYT_X;
    assign o_reg_wr_en  = (o_valid && i_ready) ? w_reg_wr_en  : 1'h0;
    assign o_reg_wr_src = (o_valid && i_ready) ? w_reg_wr_src : `REG_WR_SRC_X;

    assign o_gpr_rs1_id = (o_valid && i_ready) ? w_inst_rs1_id : 5'h0;
    assign o_gpr_rs2_id = (o_valid && i_ready) ? w_inst_rs2_id : 5'h0;
    assign o_gpr_rd_id  = (o_valid && i_ready) ? w_inst_rd_id  : 5'h0;

    always_comb begin
        if (o_valid && i_ready) begin
            o_rs1_data = (w_alu_rs1 === `ALU_RS1_GPR) ? i_gpr_rs1_data :
                         (w_alu_rs1 === `ALU_RS1_PC)  ? i_pc :
                                                        {{DATA_WIDTH{1'h0}}};
            o_rs2_data = (w_alu_rs2 === `ALU_RS2_GPR)   ? i_gpr_rs2_data :
                         (w_alu_rs2 === `ALU_RS2_IMM_I) ? w_inst_imm :
                         (w_alu_rs2 === `ALU_RS2_IMM_S) ? w_inst_imm :
                         (w_alu_rs2 === `ALU_RS2_IMM_B) ? w_inst_imm :
                         (w_alu_rs2 === `ALU_RS2_IMM_U) ? w_inst_imm :
                         (w_alu_rs2 === `ALU_RS2_IMM_J) ? w_inst_imm :
                                                          {{DATA_WIDTH{1'h0}}};
        end
        else begin
            o_rs1_data = {{DATA_WIDTH{1'h0}}};
            o_rs2_data = {{DATA_WIDTH{1'h0}}};
        end
    end

endmodule