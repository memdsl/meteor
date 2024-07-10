package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class IDU extends Module with ConfigInstRV32I
                         with ConfigInstRV32M
                         with ConfigInstRVPri {
    val io = IO(new Bundle {
        val iReadyFrIFU2IDU = Input(Bool())
        val iReadyFrIDU2EXU = Input(Bool())
        val iInst           = Input(UInt(INST_WIDTH.W))
        val iPC             = Input(UInt(ADDR_WIDTH.W))
        val iPCNext         = Input(UInt(ADDR_WIDTH.W))
        val oValidToIFU2IDU = Output(Bool())
        val oValidToIDU2EXU = Output(Bool())
        val oPC             = Output(UInt(ADDR_WIDTH.W))
        val oPCNext         = Output(UInt(ADDR_WIDTH.W))
        val oInst           = Output(UInt(INST_WIDTH.W))

        val iGPRRS1Data     = Input(UInt(DATA_WIDTH.W))
        val iGPRRS2Data     = Input(UInt(DATA_WIDTH.W))
        val oCtrInstName    = Output(UInt(SIGS_WIDTH.W))
        val oCtrALUType     = Output(UInt(SIGS_WIDTH.W))
        val oCtrALURS1      = Output(UInt(SIGS_WIDTH.W))
        val oCtrALURS2      = Output(UInt(SIGS_WIDTH.W))
        val oCtrJmpEn       = Output(Bool())
        val oCtrMemWrEn     = Output(Bool())
        val oCtrMemByt      = Output(UInt(SIGS_WIDTH.W))
        val oCtrRegWrEn     = Output(Bool())
        val oCtrRegWrSrc    = Output(UInt(SIGS_WIDTH.W))
        val oGPRRS1Addr     = Output(UInt(GPRS_WIDTH.W))
        val oGPRRS2Addr     = Output(UInt(GPRS_WIDTH.W))
        val oGPRRdAddr      = Output(UInt(GPRS_WIDTH.W))
        val oGPRRS2Data     = Output(UInt(DATA_WIDTH.W))
        val oALURS1Data     = Output(UInt(DATA_WIDTH.W))
        val oALURS2Data     = Output(UInt(DATA_WIDTH.W))
    })

    val wHandShakeIFU2IDU = io.oValidToIFU2IDU && io.iReadyFrIFU2IDU
    val wHandShakeIDU2EXU = io.oValidToIDU2EXU && io.iReadyFrIDU2EXU

    io.oValidToIFU2IDU := true.B
    io.oValidToIDU2EXU := true.B

    val wPC     = Mux(wHandShakeIFU2IDU, io.iPC,     ADDR_ZERO)
    val wPCNext = Mux(wHandShakeIFU2IDU, io.iPCNext, ADDR_ZERO)
    val wInst   = Mux(wHandShakeIFU2IDU, io.iInst,   INST_ZERO)

    io.oPC     := Mux(wHandShakeIDU2EXU, wPC,     ADDR_ZERO)
    io.oPCNext := Mux(wHandShakeIDU2EXU, wPCNext, ADDR_ZERO)
    io.oInst   := Mux(wHandShakeIDU2EXU, wInst,   INST_ZERO)

    var lInst = ListLookup(
        io.iInst,
        List(INST_NAME_X, ALU_TYPE_X, ALU_RS1_X, ALU_RS2_X, JMP_FL, MEM_WR_FL, MEM_BYT_X, REG_WR_FL, REG_WR_SRC_X),
        Array(
            INST_SLL    -> List(INST_NAME_SLL,    ALU_TYPE_SLL,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SLLI   -> List(INST_NAME_SLLI,   ALU_TYPE_SLL,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SRL    -> List(INST_NAME_SRL,    ALU_TYPE_SRL,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SRLI   -> List(INST_NAME_SRLI,   ALU_TYPE_SRL,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SRA    -> List(INST_NAME_SRA,    ALU_TYPE_SRA,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SRAI   -> List(INST_NAME_SRAI,   ALU_TYPE_SRA,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_ADD    -> List(INST_NAME_ADD,    ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_ADDI   -> List(INST_NAME_ADDI,   ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SUB    -> List(INST_NAME_SUB,    ALU_TYPE_SUB,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_LUI    -> List(INST_NAME_LUI,    ALU_TYPE_ADD,    ALU_RS1_X,    ALU_RS2_IMM_U, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_AUIPC  -> List(INST_NAME_AUIPC,  ALU_TYPE_ADD,    ALU_RS1_PC,   ALU_RS2_IMM_U, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_XOR    -> List(INST_NAME_XOR,    ALU_TYPE_XOR,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_XORI   -> List(INST_NAME_XORI,   ALU_TYPE_XOR,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_OR     -> List(INST_NAME_OR,     ALU_TYPE_OR,     ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_ORI    -> List(INST_NAME_ORI,    ALU_TYPE_OR,     ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_AND    -> List(INST_NAME_AND,    ALU_TYPE_AND,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_ANDI   -> List(INST_NAME_ANDI,   ALU_TYPE_AND,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SLT    -> List(INST_NAME_SLT,    ALU_TYPE_SLT,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SLTI   -> List(INST_NAME_SLTI,   ALU_TYPE_SLT,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SLTU   -> List(INST_NAME_SLTU,   ALU_TYPE_SLTU,   ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_SLTIU  -> List(INST_NAME_SLTIU,  ALU_TYPE_SLTU,   ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_BEQ    -> List(INST_NAME_BEQ,    ALU_TYPE_BEQ,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_BNE    -> List(INST_NAME_BNE,    ALU_TYPE_BNE,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_BLT    -> List(INST_NAME_BLT,    ALU_TYPE_BLT,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_BGE    -> List(INST_NAME_BGE,    ALU_TYPE_BGE,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_BLTU   -> List(INST_NAME_BLTU,   ALU_TYPE_BLTU,   ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_BGEU   -> List(INST_NAME_BGEU,   ALU_TYPE_BGEU,   ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_JAL    -> List(INST_NAME_JAL,    ALU_TYPE_ADD,    ALU_RS1_PC,   ALU_RS2_IMM_J, JMP_TR, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_PC),
            INST_JALR   -> List(INST_NAME_JALR,   ALU_TYPE_JALR,   ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_TR, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_PC),
            INST_FENCE  -> List(INST_NAME_FENCE,  ALU_TYPE_X,      ALU_RS1_X,    ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_FENCEI -> List(INST_NAME_FENCEI, ALU_TYPE_X,      ALU_RS1_X,    ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_ECALL  -> List(INST_NAME_ECALL,  ALU_TYPE_X,      ALU_RS1_X,    ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_EBREAK -> List(INST_NAME_EBREAK, ALU_TYPE_X,      ALU_RS1_X,    ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X),
            INST_CSRRW  -> List(INST_NAME_CSRRW,  ALU_TYPE_OR,     ALU_RS1_GPR,  ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_CSR),
            INST_CSRRS  -> List(INST_NAME_CSRRS,  ALU_TYPE_OR,     ALU_RS1_GPR,  ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_CSR),
            INST_CSRRC  -> List(INST_NAME_CSRRC,  ALU_TYPE_AND,    ALU_RS1_GPR,  ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_CSR),
            INST_CSRRWI -> List(INST_NAME_CSRRWI, ALU_TYPE_OR,     ALU_RS1_IMM,  ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_CSR),
            INST_CSRRSI -> List(INST_NAME_CSRRSI, ALU_TYPE_OR,     ALU_RS1_IMM,  ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_CSR),
            INST_CSRRCI -> List(INST_NAME_CSRRCI, ALU_TYPE_AND,    ALU_RS1_IMM,  ALU_RS2_X,     JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_CSR),
            INST_LB     -> List(INST_NAME_LB,     ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_1_S, REG_WR_TR, REG_WR_SRC_MEM),
            INST_LH     -> List(INST_NAME_LH,     ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_2_S, REG_WR_TR, REG_WR_SRC_MEM),
            INST_LBU    -> List(INST_NAME_LBU,    ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_1_U, REG_WR_TR, REG_WR_SRC_MEM),
            INST_LHU    -> List(INST_NAME_LHU,    ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_2_U, REG_WR_TR, REG_WR_SRC_MEM),
            INST_LW     -> List(INST_NAME_LW,     ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_I, JMP_FL, MEM_WR_FL, MEM_BYT_4_S, REG_WR_TR, REG_WR_SRC_MEM),
            INST_SB     -> List(INST_NAME_SB,     ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_S, JMP_FL, MEM_WR_TR, MEM_BYT_1_U, REG_WR_FL, REG_WR_SRC_X),
            INST_SH     -> List(INST_NAME_SH,     ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_S, JMP_FL, MEM_WR_TR, MEM_BYT_2_U, REG_WR_FL, REG_WR_SRC_X),
            INST_SW     -> List(INST_NAME_SW,     ALU_TYPE_ADD,    ALU_RS1_GPR,  ALU_RS2_IMM_S, JMP_FL, MEM_WR_TR, MEM_BYT_4_U, REG_WR_FL, REG_WR_SRC_X),

            INST_MUL    -> List(INST_NAME_MUL,    ALU_TYPE_MUL,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_MULH   -> List(INST_NAME_MULH,   ALU_TYPE_MULH,   ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_MULHSU -> List(INST_NAME_MULHSU, ALU_TYPE_MULHSU, ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_MULHU  -> List(INST_NAME_MULHU,  ALU_TYPE_MULHU,  ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_DIV    -> List(INST_NAME_DIV,    ALU_TYPE_DIV,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_DIVU   -> List(INST_NAME_DIVU,   ALU_TYPE_DIVU,   ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_REM    -> List(INST_NAME_REM,    ALU_TYPE_REM,    ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),
            INST_REMU   -> List(INST_NAME_REMU,   ALU_TYPE_REMU,   ALU_RS1_GPR,  ALU_RS2_GPR,   JMP_FL, MEM_WR_FL, MEM_BYT_X,   REG_WR_TR, REG_WR_SRC_ALU),

            INST_MRET   -> List(INST_NAME_MRET,   ALU_TYPE_ADD,    ALU_RS1_X,    ALU_RS2_X,     JMP_TR, MEM_WR_FL, MEM_BYT_X,   REG_WR_FL, REG_WR_SRC_X)
        )
    )
    val wInstName = lInst(0)
    val wALUType  = lInst(1)
    val wALURS1   = lInst(2)
    val wALURS2   = lInst(3)
    val wJmpEn    = lInst(4)
    val wMemWrEn  = lInst(5)
    val wMemByt   = lInst(6)
    val wRegWrEn  = lInst(7)
    val wRegWrSrc = lInst(8)

    val wCtrInstName = Mux(wHandShakeIFU2IDU, wInstName, SIGS_ZERO)
    val wCtrALUType  = Mux(wHandShakeIFU2IDU, wALUType,  SIGS_ZERO)
    val wCtrALURS1   = Mux(wHandShakeIFU2IDU, wALURS1,   SIGS_ZERO)
    val wCtrALURS2   = Mux(wHandShakeIFU2IDU, wALURS2,   SIGS_ZERO)
    val wCtrJmpEn    = Mux(wHandShakeIFU2IDU, wJmpEn,    SIGS_ZERO)
    val wCtrMemWrEn  = Mux(wHandShakeIFU2IDU, wMemWrEn,  SIGS_ZERO)
    val wCtrMemByt   = Mux(wHandShakeIFU2IDU, wMemByt,   SIGS_ZERO)
    val wCtrRegWrEn  = Mux(wHandShakeIFU2IDU, wRegWrEn,  SIGS_ZERO)
    val wCtrRegWrSrc = Mux(wHandShakeIFU2IDU, wRegWrSrc, SIGS_ZERO)

    io.oCtrInstName := Mux(wHandShakeIDU2EXU, wCtrInstName, SIGS_ZERO)
    io.oCtrALUType  := Mux(wHandShakeIDU2EXU, wCtrALUType,  SIGS_ZERO)
    io.oCtrALURS1   := Mux(wHandShakeIDU2EXU, wCtrALURS1,   SIGS_ZERO)
    io.oCtrALURS2   := Mux(wHandShakeIDU2EXU, wCtrALURS2,   SIGS_ZERO)
    io.oCtrJmpEn    := Mux(wHandShakeIDU2EXU, wCtrJmpEn,    SIGS_ZERO)
    io.oCtrMemWrEn  := Mux(wHandShakeIDU2EXU, wCtrMemWrEn,  SIGS_ZERO)
    io.oCtrMemByt   := Mux(wHandShakeIDU2EXU, wCtrMemByt,   SIGS_ZERO)
    io.oCtrRegWrEn  := Mux(wHandShakeIDU2EXU, wCtrRegWrEn,  SIGS_ZERO)
    io.oCtrRegWrSrc := Mux(wHandShakeIDU2EXU, wCtrRegWrSrc, SIGS_ZERO)

    val wGPRRS1Addr = Mux(wHandShakeIFU2IDU, io.iInst(19, 15), GPRS_ZERO)
    val wGPRRS2Addr = Mux(wHandShakeIFU2IDU, io.iInst(24, 20), GPRS_ZERO)
    val wGPRRdAddr  = Mux(wHandShakeIFU2IDU, io.iInst(11,  7), GPRS_ZERO)

    val wGPRRS1Data = io.iGPRRS1Data
    val wGPRRS2Data = io.iGPRRS2Data

    val wALURS1Data = Mux(wHandShakeIFU2IDU, wGPRRS1Data, DATA_ZERO)
    val wALURS2Data = Mux(wHandShakeIFU2IDU, wGPRRS2Data, DATA_ZERO)

    io.oGPRRS1Addr := Mux(wHandShakeIDU2EXU, wGPRRS1Addr,    GPRS_ZERO)
    io.oGPRRS2Addr := Mux(wHandShakeIDU2EXU, wGPRRS2Addr,    GPRS_ZERO)
    io.oGPRRdAddr  := Mux(wHandShakeIDU2EXU, wGPRRdAddr,     GPRS_ZERO)
    io.oGPRRS2Data := Mux(wHandShakeIDU2EXU, io.iGPRRS2Data, DATA_ZERO)
    io.oALURS1Data := Mux(wHandShakeIDU2EXU, wALURS1Data,    DATA_ZERO)
    io.oALURS2Data := Mux(wHandShakeIDU2EXU, wALURS2Data,    DATA_ZERO)
}
