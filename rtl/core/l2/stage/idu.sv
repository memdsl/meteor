module idu(
    input  logic                       i_i2i_valid,
    output logic                       o_idu_ready,
    input  logic                       i_i2e_ready,
    output logic                       o_idu_valid,

    input  logic [`INST_WIDTH - 1 : 0] i_rom_inst,

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

    input  logic [`DATA_WIDTH - 1 : 0] i_gpr_rs1_data,
    input  logic [`DATA_WIDTH - 1 : 0] i_gpr_rs2_data,
    output logic [`GPRS_WIDTH - 1 : 0] o_idu_gpr_rs1_id,
    output logic [`GPRS_WIDTH - 1 : 0] o_idu_gpr_rs2_id,
    output logic [`GPRS_WIDTH - 1 : 0] o_idu_gpr_rd_id,

    input  logic [`ADDR_WIDTH - 1 : 0] i_i2i_pc,
    output logic [`ADDR_WIDTH - 1 : 0] o_idu_pc,
    output logic [`DATA_WIDTH - 1 : 0] o_idu_rs1_data,
    output logic [`DATA_WIDTH - 1 : 0] o_idu_rs2_data,

    output logic [`DATA_WIDTH - 1 : 0] o_idu_jmp_or_reg_data,
    output logic                       o_idu_end_flag
);

    assign o_idu_ready = 1'b1;
    assign o_idu_valid = 1'b1;

    logic [              6 : 0] w_inst_opcode;
    logic [              2 : 0] w_inst_funct3;
    logic [              6 : 0] w_inst_funct7;
    logic [`GPRS_WIDTH - 1 : 0] w_inst_rs1_id;
    logic [`GPRS_WIDTH - 1 : 0] w_inst_rs2_id;
    logic [`GPRS_WIDTH - 1 : 0] w_inst_rd_id;
    logic [`DATA_WIDTH - 1 : 0] w_inst_imm;

    assign w_inst_opcode = i_ram_inst[ 6 :  0];
    assign w_inst_funct3 = i_ram_inst[14 : 12];
    assign w_inst_funct7 = i_ram_inst[31 : 25];
    assign w_inst_rs1_id = i_ram_inst[19 : 15];
    assign w_inst_rs2_id = i_ram_inst[24 : 20];
    assign w_inst_rd_id  = i_ram_inst[11 :  7];

    imm u_imm(
        .i_imm_inst  (i_ram_inst   ),
        .i_imm_opcode(w_inst_opcode),
        .o_imm_data  (w_inst_imm   )
    );

    logic [`ARGS_WIDTH - 1 : 0] w_ctr_inst_type;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_inst_name;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_alu_type;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_alu_rs1;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_alu_rs2;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_jmp_type;
    logic                       w_ctr_ram_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_ram_byt;
    logic                       w_ctr_reg_wr_en;
    logic [`ARGS_WIDTH - 1 : 0] w_ctr_reg_wr_src;

    always_comb begin
        case (w_inst_opcode)
            // LUI
            7'b0110111: begin
                w_ctr_inst_type  = `INST_TYPE_LUI;
                w_ctr_inst_name  = `INST_NAME_LUI;
                w_ctr_alu_type   = `ALU_TYPE_ADD;
                w_ctr_alu_rs1    = `ALU_RS1_X;
                w_ctr_alu_rs2    = `ALU_RS2_IMM_U;
                w_ctr_jmp_type   = `JMP_X;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_ram_byt    = `RAM_BYT_X;
                w_ctr_reg_wr_en  = 1'b1;
                w_ctr_reg_wr_src = `REG_WR_SRC_ALU;
            end
            // AUIPC
            7'b0010111: begin
                w_ctr_inst_type  = `INST_TYPE_AUIPC;
                w_ctr_inst_name  = `INST_NAME_AUIPC;
                w_ctr_alu_type   = `ALU_TYPE_ADD;
                w_ctr_alu_rs1    = `ALU_RS1_PC;
                w_ctr_alu_rs2    = `ALU_RS2_IMM_U;
                w_ctr_jmp_type   = `JMP_X;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_ram_byt    = `RAM_BYT_X;
                w_ctr_reg_wr_en  = 1'b1;
                w_ctr_reg_wr_src = `REG_WR_SRC_ALU;
            end
            // JAL
            7'b1101111: begin
                w_ctr_inst_type  = `INST_TYPE_JMP;
                w_ctr_inst_name  = `INST_NAME_JAL;
                w_ctr_alu_type   = `ALU_TYPE_ADD;
                w_ctr_alu_rs1    = `ALU_RS1_PC;
                w_ctr_alu_rs2    = `ALU_RS2_IMM_J;
                w_ctr_jmp_type   = `JMP_J;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_ram_byt    = `RAM_BYT_X;
                w_ctr_reg_wr_en  = 1'b1;
                w_ctr_reg_wr_src = `REG_WR_SRC_PC;
            end
            // JALR
            7'b1100111: begin
                w_ctr_inst_type  = `INST_TYPE_JMP;
                w_ctr_inst_name  = `INST_NAME_JALR;
                w_ctr_alu_type   = `ALU_TYPE_JALR;
                w_ctr_alu_rs1    = `ALU_RS1_GPR;
                w_ctr_alu_rs2    = `ALU_RS2_IMM_I;
                w_ctr_jmp_type   = `JMP_J;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_ram_byt    = `RAM_BYT_X;
                w_ctr_reg_wr_en  = 1'b1;
                w_ctr_reg_wr_src = `REG_WR_SRC_PC;
            end
            // BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                case (w_inst_funct3)
                    3'b000: begin
                        w_ctr_inst_name = `INST_NAME_BEQ;
                        w_ctr_alu_type  = `ALU_TYPE_BEQ;
                    end
                    3'b001: begin
                        w_ctr_inst_name = `INST_NAME_BNE;
                        w_ctr_alu_type  = `ALU_TYPE_BNE;
                    end
                    3'b100: begin
                        w_ctr_inst_name = `INST_NAME_BLT;
                        w_ctr_alu_type  = `ALU_TYPE_BLT;
                    end
                    3'b101: begin
                        w_ctr_inst_name = `INST_NAME_BGE;
                        w_ctr_alu_type  = `ALU_TYPE_BGE;
                    end
                    3'b110: begin
                        w_ctr_inst_name = `INST_NAME_BLTU;
                        w_ctr_alu_type  = `ALU_TYPE_BLTU;
                    end
                    3'b111: begin
                        w_ctr_inst_name = `INST_NAME_BGEU;
                        w_ctr_alu_type  = `ALU_TYPE_BGEU;
                    end
                    default: begin
                        w_ctr_inst_name = `INST_NAME_X;
                        w_ctr_alu_type  = `ALU_TYPE_X;
                    end
                endcase
                w_ctr_inst_type  = `INST_TYPE_BRH;
                w_ctr_alu_rs1    = `ALU_RS1_GPR;
                w_ctr_alu_rs2    = `ALU_RS2_GPR;
                w_ctr_jmp_type   = `JMP_B;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_ram_byt    = `RAM_BYT_X;
                w_ctr_reg_wr_en  = 1'b0;
                w_ctr_reg_wr_src = `REG_WR_SRC_X;
            end
            // LB, LH, LW, LBU, LHU
            7'b0000011: begin
                case (w_inst_funct3)
                    3'b000: begin
                        w_ctr_inst_name = `INST_NAME_LB;
                        w_ctr_ram_byt   = `RAM_BYT_1_S;
                    end
                    3'b001: begin
                        w_ctr_inst_name = `INST_NAME_LH;
                        w_ctr_ram_byt   = `RAM_BYT_2_S;
                    end
                    3'b010: begin
                        w_ctr_inst_name = `INST_NAME_LW;
                        w_ctr_ram_byt   = `RAM_BYT_4_S;
                    end
                    3'b100: begin
                        w_ctr_inst_name = `INST_NAME_LBU;
                        w_ctr_ram_byt   = `RAM_BYT_1_U;
                    end
                    3'b101: begin
                        w_ctr_inst_name = `INST_NAME_LHU
                        w_ctr_ram_byt   = `RAM_BYT_2_U;
                    end
                    default: begin
                        w_ctr_inst_name = `INST_NAME_X;
                        w_ctr_ram_byt   = `RAM_BYT_X;
                    end
                endcase
                w_ctr_inst_type  = `INST_TYPE_LOAD;
                w_ctr_alu_type   = `ALU_TYPE_ADD;
                w_ctr_alu_rs1    = `ALU_RS1_GPR;
                w_ctr_alu_rs2    = `ALU_RS2_IMM_I;
                w_ctr_jmp_type   = `JMP_X;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_reg_wr_en  = 1'b1;
                w_ctr_reg_wr_src = `REG_WR_SRC_MEM;
            end
            // SB, SH, SW
            7'b0100011: begin
                case (w_inst_funct3)
                    3'b000: begin
                        w_ctr_inst_name = `INST_NAME_SB;
                        w_ctr_ram_byt   = `RAM_BYT_1_U;
                    end
                    3'b001: begin
                        w_ctr_inst_name = `INST_NAME_SH;
                        w_ctr_ram_byt   = `RAM_BYT_2_U;
                    end
                    3'b010: begin
                        w_ctr_inst_name = `INST_NAME_SW;
                        w_ctr_ram_byt   = `RAM_BYT_4_U;
                    end
                    default: begin
                        w_ctr_inst_name = `INST_NAME_X;
                        w_ctr_ram_byt   = `RAM_BYT_X;
                    end
                endcase
                w_ctr_inst_type  = `INST_TYPE_STOR;
                w_ctr_alu_type   = `ALU_TYPE_ADD;
                w_ctr_alu_rs1    = `ALU_RS1_GPR;
                w_ctr_alu_rs2    = `ALU_RS2_IMM_S;
                w_ctr_jmp_type   = `JMP_X;
                w_ctr_ram_wr_en  = 1'b1;
                w_ctr_reg_wr_en  = 1'b0;
                w_ctr_reg_wr_src = `REG_WR_SRC_X;
            end
            // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            7'b0010011: begin
                case (w_inst_funct3)
                    3'b000: begin
                        w_ctr_inst_name = `INST_NAME_ADDI;
                        w_ctr_alu_type  = `ALU_TYPE_ADD;
                    end;
                    3'b010: begin
                        w_ctr_inst_name = `INST_NAME_SLTI;
                        w_ctr_alu_type  = `ALU_TYPE_SLT;
                    end
                    3'b011: begin
                        w_ctr_inst_name = `INST_NAME_SLTIU;
                        w_ctr_alu_type  = `ALU_TYPE_SLTU;
                    end
                    3'b100: begin
                        w_ctr_inst_name = `INST_NAME_XORI;
                        w_ctr_alu_type  = `ALU_TYPE_XOR;
                    end
                    3'b110: begin
                        w_ctr_inst_name = `INST_NAME_ORI;
                        w_ctr_alu_type  = `ALU_TYPE_OR;
                    end
                    3'b111: begin
                        w_ctr_inst_name = `INST_NAME_ANDI;
                        w_ctr_alu_type  = `ALU_TYPE_AND;
                    end
                    3'b001: begin
                        w_ctr_inst_name = `INST_NAME_SLLI;
                        w_ctr_alu_type  = `ALU_TYPE_SLL;
                    end
                    3'b101: begin
                        if (w_inst_funct7 === 7'b0000000) begin
                            w_ctr_inst_name = `INST_NAME_SRLI;
                            w_ctr_alu_type  = `ALU_TYPE_SRL;
                        end
                        else begin
                            w_ctr_inst_name = `INST_NAME_SRAI;
                            w_ctr_alu_type  = `ALU_TYPE_SRA;
                        end
                    end
                    default: begin
                        w_ctr_inst_name = `INST_NAME_X;
                        w_ctr_alu_type  = `ALU_TYPE_X;
                    end
                endcase
                w_ctr_inst_type  = `INST_TYPE_R_I;
                w_ctr_alu_rs1    = `ALU_RS1_GPR;
                w_ctr_alu_rs2    = `ALU_RS2_IMM_I;
                w_ctr_jmp_type   = `JMP_X;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_ram_byt    = `RAM_BYT_X;
                w_ctr_reg_wr_en  = 1'b1;
                w_ctr_reg_wr_src = `REG_WR_SRC_ALU;
            end
            // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            7'b0110011: begin
                case (w_inst_funct3)
                    3'b000: begin
                        if (w_inst_funct7 === 7'b0000000) begin
                            w_ctr_inst_name = `INST_NAME_ADD;
                            w_ctr_alu_type  = `ALU_TYPE_ADD;
                        end
                        else begin
                            w_ctr_inst_name = `INST_NAME_SUB;
                            w_ctr_alu_type  = `ALU_TYPE_SUB;
                        end
                    end
                    3'b001: begin
                        w_ctr_inst_name = `INST_NAME_SLL;
                        w_ctr_alu_type  = `ALU_TYPE_SLL;
                    end
                    3'b010: begin
                        w_ctr_inst_name = `INST_NAME_SLT;
                        w_ctr_alu_type  = `ALU_TYPE_SLT;
                    end
                    3'b011: begin
                        w_ctr_inst_name = `INST_NAME_SLTU;
                        w_ctr_alu_type  = `ALU_TYPE_SLTU;
                    end
                    3'b100: begin
                        w_ctr_inst_name = `INST_NAME_XOR;
                        w_ctr_alu_type  = `ALU_TYPE_XOR;
                    end
                    3'b101: begin
                        if (w_inst_funct7 === 7'b0000000) begin
                            w_ctr_inst_name = `INST_NAME_SRL;
                            w_ctr_alu_type  = `ALU_TYPE_SRL;
                        end
                        else begin
                            w_ctr_inst_name = `INST_NAME_SRA;
                            w_ctr_alu_type  = `ALU_TYPE_SRA;
                        end
                    end
                    3'b110: begin
                        w_ctr_inst_name = `INST_NAME_OR;
                        w_ctr_alu_type  = `ALU_TYPE_OR;
                    end
                    3'b111: begin
                        w_ctr_inst_name = `INST_NAME_AND;
                        w_ctr_alu_type  = `ALU_TYPE_AND;
                    end
                    default: begin
                        w_ctr_inst_name = `INST_NAME_X;
                        w_ctr_alu_type  = `ALU_TYPE_X;
                    end
                endcase
                w_ctr_inst_type  = `INST_TYPE_R_R;
                w_ctr_alu_rs1    = `ALU_RS1_GPR;
                w_ctr_alu_rs2    = `ALU_RS2_GPR;
                w_ctr_jmp_type   = `JMP_X;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_ram_byt    = `RAM_BYT_X;
                w_ctr_reg_wr_en  = 1'b1;
                w_ctr_reg_wr_src = `REG_WR_SRC_ALU;
            end
            default: begin
                w_ctr_inst_type  = `INST_TYPE_X;
                w_ctr_inst_name  = `INST_NAME_X;
                w_ctr_alu_type   = `ALU_TYPE_X;
                w_ctr_alu_rs1    = `ALU_RS1_X;
                w_ctr_alu_rs2    = `ALU_RS2_X;
                w_ctr_jmp_type   = `JMP_X;
                w_ctr_ram_wr_en  = 1'b0;
                w_ctr_ram_byt    = `RAM_BYT_X;
                w_ctr_reg_wr_en  = 1'b0;
                w_ctr_reg_wr_src = `REG_WR_SRC_X;
            end
        endcase
    end

    assign o_idu_ctr_inst_type  = (i_i2i_valid && o_idu_ready) ? w_ctr_inst_type  : `INST_TYPE_X;
    assign o_idu_ctr_inst_name  = (i_i2i_valid && o_idu_ready) ? w_ctr_inst_name  : `INST_NAME_X;
    assign o_idu_ctr_alu_type   = (i_i2i_valid && o_idu_ready) ? w_ctr_alu_type   : `ALU_TYPE_X;
    assign o_idu_ctr_alu_rs1    = (i_i2i_valid && o_idu_ready) ? w_ctr_alu_rs1    : `ALU_RS1_X;
    assign o_idu_ctr_alu_rs2    = (i_i2i_valid && o_idu_ready) ? w_ctr_alu_rs2    : `ALU_RS2_X;
    assign o_idu_ctr_jmp_type   = (i_i2i_valid && o_idu_ready) ? w_ctr_jmp_type   : `JMP_X;
    assign o_idu_ctr_ram_wr_en  = (i_i2i_valid && o_idu_ready) ? w_ctr_ram_wr_en  : 1'b0;
    assign o_idu_ctr_ram_byt    = (i_i2i_valid && o_idu_ready) ? w_ctr_ram_byt    : `RAM_BYT_X;
    assign o_idu_ctr_reg_wr_en  = (i_i2i_valid && o_idu_ready) ? w_ctr_reg_wr_en  : 1'b0;
    assign o_idu_ctr_reg_wr_src = (i_i2i_valid && o_idu_ready) ? w_ctr_reg_wr_src : `REG_WR_SRC_X;

    assign o_idu_gpr_rs1_id = (i_i2i_valid && o_idu_ready) ? w_inst_rs1_id : 5'h0;
    assign o_idu_gpr_rs2_id = (i_i2i_valid && o_idu_ready) ? w_inst_rs2_id : 5'h0;
    assign o_idu_gpr_rd_id  = (i_i2i_valid && o_idu_ready) ? w_inst_rd_id  : 5'h0;

    assign o_idu_pc = (i_i2i_valid && o_idu_ready) ? i_i2i_pc : `ADDR_ZERO;
    always_comb begin
        if (i_i2i_valid && o_idu_ready) begin
            o_idu_rs1_data = (w_ctr_alu_rs1 === `ALU_RS1_GPR) ? i_gpr_rs1_data :
                             (w_ctr_alu_rs1 === `ALU_RS1_PC ) ? i_i2i_pc       :
                                                               `DATA_ZERO;
            o_idu_rs2_data = (w_ctr_alu_rs2 === `ALU_RS2_GPR  ) ? i_gpr_rs2_data :
                             (w_ctr_alu_rs2 === `ALU_RS2_IMM_I) ? w_inst_imm     :
                             (w_ctr_alu_rs2 === `ALU_RS2_IMM_S) ? w_inst_imm     :
                             (w_ctr_alu_rs2 === `ALU_RS2_IMM_B) ? w_inst_imm     :
                             (w_ctr_alu_rs2 === `ALU_RS2_IMM_U) ? w_inst_imm     :
                             (w_ctr_alu_rs2 === `ALU_RS2_IMM_J) ? w_inst_imm     :
                                                                 `DATA_ZERO;
        end
        else begin
            o_idu_rs1_data = `DATA_ZERO;
            o_idu_rs2_data = `DATA_ZERO;
        end
    end

    always_comb begin
        if (i_i2i_valid && o_idu_ready) begin
            if (w_ctr_jmp_type === `JMP_B ) begin
                o_idu_jmp_or_reg_data = w_inst_imm;
            end
            else begin
                o_idu_jmp_or_reg_data = i_gpr_rs2_data;
            end
        end
        else begin
            o_idu_jmp_or_reg_data = `DATA_ZERO;
        end
    end

    always_comb begin
        if (i_i2i_valid && o_idu_ready) begin
            if (w_inst_opcode == 7'b1110011 && i_ram_inst[31 : 20] == 12'h0001) begin
                o_idu_end_flag = 1'b1;
            end
            else begin
                o_idu_end_flag = 1'b0;
            end
        end
        else begin
            o_idu_end_flag = 1'b0;
        end
    end

endmodule
