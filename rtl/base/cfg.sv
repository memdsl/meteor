`define ADDR_WIDTH 32
`define DATA_WIDTH 32
`define INST_WIDTH 32
`define GPRS_WIDTH  5
`define ARGS_WIDTH  8
`define BYTE_WIDTH  8

`define ADDR_INIT 32'h8000_0000

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

`define ALU_RS1_X   0
`define ALU_RS1_GPR 1
`define ALU_RS1_PC  2

`define ALU_RS2_X     0
`define ALU_RS2_GPR   1
`define ALU_RS2_IMM_I 2
`define ALU_RS2_IMM_S 3
`define ALU_RS2_IMM_B 4
`define ALU_RS2_IMM_U 5
`define ALU_RS2_IMM_J 6

`define JMP_X 0
`define JMP_J 1
`define JMP_B 2
`define JMP_E 3

`define RAM_BYT_X   0
`define RAM_BYT_1_U 1
`define RAM_BYT_2_U 2
`define RAM_BYT_4_U 3
`define RAM_BYT_8_U 4
`define RAM_BYT_1_S 5
`define RAM_BYT_2_S 6
`define RAM_BYT_4_S 7
`define RAM_BYT_8_S 8

`define REG_WR_SRC_X   0
`define REG_WR_SRC_ALU 1
`define REG_WR_SRC_MEM 2
`define REG_WR_SRC_PC  3
`define REG_WR_SRC_CSR 4
