package cpu.core.ml.me32ls

import chisel3._
import chisel3.util._

import cpu.base._
import cpu.port._
import cpu.mem._

class Top extends Module with ConfigInst {
    val io = IO(new Bundle {
        val oPC      = Output(UInt(ADDR_WIDTH.W))
        val oInst    = Output(UInt(DATA_WIDTH.W))
        val oEndFlag = Output(Bool())
        val oEndData = Output(UInt(DATA_WIDTH.W))

        val pGPRRd  =          new GPRRdIO
        val pMem     = Flipped(new MemDualIO)
    });

    val mGPR = Module(new GPR)

    val mIFU = Module(new IFU)
    val mIDU = Module(new IDU)
    val mEXU = Module(new EXU)
    val mLSU = Module(new LSU)
    val mWBU = Module(new WBU)

    io.oPC      := mIFU.io.pIFU.bPC
    io.oInst    := io.pMem.bRdDataA
    io.oEndFlag := false.B
    io.oEndData := mGPR.io.pGPRRd.bRdEData
    io.pGPRRd   <> mGPR.io.pGPRRd
    io.pMem     <> mLSU.io.pMemO

    when (mIDU.io.oInstName === INST_NAME_X) {
        assert(false.B, "Invalid instruction at 0x%x", mIFU.io.pIFU.bPC)
    }
    .elsewhen (mIDU.io.oInstName === INST_NAME_EBREAK) {
        io.oEndFlag := true.B
    }
    .otherwise {
        io.oEndFlag := false.B
    }

    mGPR.io.iRS1Addr := mIDU.io.oGPRRS1Addr
    mGPR.io.iRS2Addr := mIDU.io.oGPRRS2Addr
    mGPR.io.pGPRWr   <> mWBU.io.pGPRWrO

    mIFU.io.iJmpEn := mEXU.io.oJmpEn
    mIFU.io.iJmpPC := mEXU.io.oJmpPC

    mIDU.io.iPC         := mIFU.io.pIFU.bPC
    mIDU.io.iInst       := io.pMem.bRdDataA
    mIDU.io.iGPRRS1Data := mGPR.io.pGPRRd.bRS1Data
    mIDU.io.iGPRRS2Data := mGPR.io.pGPRRd.bRS2Data

    mEXU.io.iPC          := mIFU.io.pIFU.bPC
    mEXU.io.iInstName    := mIDU.io.oInstName
    mEXU.io.iALUType     := mIDU.io.oALUType
    mEXU.io.iJmpEn       := mIDU.io.oJmpEn
    mEXU.io.iMemWrEn     := mIDU.io.oMemWrEn
    mEXU.io.iMemByt      := mIDU.io.oMemByt
    mEXU.io.iGPRWrEn     := mIDU.io.oGPRWrEn
    mEXU.io.iGPRWrSrc    := mIDU.io.oGPRWrSrc
    mEXU.io.iGPRRdAddr   := mIDU.io.oGPRRdAddr
    mEXU.io.iALURS1Data  := mIDU.io.oALURS1Data
    mEXU.io.iALURS2Data  := mIDU.io.oALURS2Data
    mEXU.io.iJmpOrWrData := mIDU.io.oJmpOrWrData
    mEXU.io.iMemRdData   := io.pMem.bRdDataB

    mLSU.io.pMemI <> mEXU.io.pMem

    mWBU.io.pGPRWrI <> mEXU.io.pGPRWr
}
