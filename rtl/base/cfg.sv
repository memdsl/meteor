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

`define INST_NAME_X       0
`define INST_NAME_LUI     1
`define INST_NAME_AUIPC   2
`define INST_NAME_JAL     3
`define INST_NAME_JALR    4
`define INST_NAME_BEQ     5
`define INST_NAME_BNE     6
`define INST_NAME_BLT     7
`define INST_NAME_BGE     8
`define INST_NAME_BLTU    9
`define INST_NAME_BEGU   10
`define INST_NAME_LB     11
`define INST_NAME_LH     12
`define INST_NAME_LW     13
`define INST_NAME_LBU    14
`define INST_NAME_LHU    15
`define INST_NAME_SB     16
`define INST_NAME_SH     17
`define INST_NAME_SW     18
`define INST_NAME_ADDI   19
`define INST_NAME_SLTI   20
`define INST_NAME_SLTIU  21
`define INST_NAME_XORI   22
`define INST_NAME_ORI    23
`define INST_NAME_ANDI   24
`define INST_NAME_SLLI   25
`define INST_NAME_SRLI   26
`define INST_NAME_SRAI   27
`define INST_NAME_ADD    28
`define INST_NAME_SUB    29
`define INST_NAME_SLL    30
`define INST_NAME_SLT    31
`define INST_NAME_SLTU   32
`define INST_NAME_XOR    33
`define INST_NAME_SRL    34
`define INST_NAME_SRA    35
`define INST_NAME_OR     36
`define INST_NAME_AND    37
`define INST_NAME_FENCE  38
`define INST_NAME_FENCEI 39
`define INST_NAME_ECALL  40
`define INST_NAME_EBREAK 41
`define INST_NAME_CSRRW  42
`define INST_NAME_CSRRS  43
`define INST_NAME_CSRRC  44
`define INST_NAME_CSRRWI 45
`define INST_NAME_CSRRSI 46
`define INST_NAME_CSRRCI 47

`define INST_TYPE_X     0
`define INST_TYPE_LUI   1
`define INST_TYPE_AUIPC 2
`define INST_TYPE_JMP   3
`define INST_TYPE_BRH   4
`define INST_TYPE_LOAD  5
`define INST_TYPE_STOR  6
`define INST_TYPE_R_I   7
`define INST_TYPE_R_R   8

`define SIGN_EXTEND(data, width) \
    {{(width - $bits(data)){data[$bits(data) - 1]}}, data}
`define ZERO_EXTEND(data, width) \
    {{(width - $bits(data)){                 1'b0}}, data}