`define ADDR_WIDTH 32
`define DATA_WIDTH 32
`define INST_WIDTH 32
`define GPRS_WIDTH  5
`define ARGS_WIDTH  8
`define BYTE_WIDTH  8

`define ADDR_INIT 32'h0000_0000
`define DATA_ZERO 0

// 32bit: 4KB
`define ROM_BITS 10
`define ROM_SIZE  1 << `ROM_BITS

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
`define RAM_BYT_1_S 5
`define RAM_BYT_2_S 6
`define RAM_BYT_4_S 7

`define REG_WR_SRC_X   0
`define REG_WR_SRC_ALU 1
`define REG_WR_SRC_MEM 2
`define REG_WR_SRC_PC  3
`define REG_WR_SRC_CSR 4

`define INST_NAME_LUI     0
`define INST_NAME_AUIPC   1
`define INST_NAME_JAL     2
`define INST_NAME_JALR    3
`define INST_NAME_BEQ     4
`define INST_NAME_BNE     5
`define INST_NAME_BLT     6
`define INST_NAME_BGE     7
`define INST_NAME_BLTU    8
`define INST_NAME_BEGU    9
`define INST_NAME_LB     10
`define INST_NAME_LH     11
`define INST_NAME_LW     12
`define INST_NAME_LBU    13
`define INST_NAME_LHU    14
`define INST_NAME_SB     15
`define INST_NAME_SH     16
`define INST_NAME_SW     17
`define INST_NAME_ADDI   18
`define INST_NAME_SLTI   19
`define INST_NAME_SLTIU  20
`define INST_NAME_XORI   21
`define INST_NAME_ORI    22
`define INST_NAME_ANDI   23
`define INST_NAME_SLLI   24
`define INST_NAME_SRLI   25
`define INST_NAME_SRAI   26
`define INST_NAME_ADD    27
`define INST_NAME_SUB    28
`define INST_NAME_SLL    29
`define INST_NAME_SLT    30
`define INST_NAME_SLTU   31
`define INST_NAME_XOR    32
`define INST_NAME_SRL    33
`define INST_NAME_SRA    34
`define INST_NAME_OR     35
`define INST_NAME_AND    36
`define INST_NAME_FENCE  37
`define INST_NAME_FENCEI 38
`define INST_NAME_ECALL  39
`define INST_NAME_EBREAK 40
`define INST_NAME_CSRRW  41
`define INST_NAME_CSRRS  42
`define INST_NAME_CSRRC  43
`define INST_NAME_CSRRWI 44
`define INST_NAME_CSRRSI 45
`define INST_NAME_CSRRCI 46

`define SIGN_EXTEND(data, width) \
    {{(width - $bits(data)){data[$bits(data) - 1]}}, data}
`define ZERO_EXTEND(data, width) \
    {{(width - $bits(data)){                 1'b0}}, data}