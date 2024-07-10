package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class LSU2WBU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrLSU  = Input(Bool())
        val iReadyFrWBU  = Input(Bool())
        val iPC          = Input(UInt(ADDR_WIDTH.W))
        val iPCNext      = Input(UInt(ADDR_WIDTH.W))
        val iInst        = Input(UInt(INST_WIDTH.W))
        val oValidToLSU  = Output(Bool())
        val oValidToWBU  = Output(Bool())
        val oPC          = Output(UInt(ADDR_WIDTH.W))
        val oPCNext      = Output(UInt(ADDR_WIDTH.W))
        val oInst        = Output(UInt(INST_WIDTH.W))

        val iCtrMemByt   = Input(UInt(SIGS_WIDTH.W))
        val iCtrRegWrEn  = Input(Bool())
        val iCtrRegWrSrc = Input(UInt(SIGS_WIDTH.W))
        val iGPRRdAddr   = Input(UInt(GPRS_WIDTH.W))
        val iALUZero     = Input(Bool())
        val iALUOut      = Input(UInt(DATA_WIDTH.W))
        val iMemRdData   = Input(UInt(DATA_WIDTH.W))
        val oCtrMemByt   = Output(UInt(SIGS_WIDTH.W))
        val oCtrRegWrEn  = Output(Bool())
        val oCtrRegWrSrc = Output(UInt(SIGS_WIDTH.W))
        val oGPRRdAddr   = Output(UInt(GPRS_WIDTH.W))
        val oALUZero     = Output(Bool())
        val oALUOut      = Output(UInt(DATA_WIDTH.W))
        val oMemRdData   = Output(UInt(DATA_WIDTH.W))
    })

    val wHandShakeLSU = io.oValidToLSU && io.iReadyFrLSU
    val wHandShakeWBU = io.oValidToWBU && io.iReadyFrWBU

    io.oValidToLSU := true.B
    io.oValidToWBU := true.B

    val rPC     = RegEnable(io.iPC,     ADDR_INIT, wHandShakeLSU)
    val rPCNext = RegEnable(io.iPCNext, ADDR_INIT, wHandShakeLSU)
    val rInst   = RegEnable(io.iInst,   INST_ZERO, wHandShakeLSU)

    io.oPC     := Mux(wHandShakeWBU, rPC,     ADDR_ZERO)
    io.oPCNext := Mux(wHandShakeWBU, rPCNext, ADDR_ZERO)
    io.oInst   := Mux(wHandShakeWBU, rInst,   INST_ZERO)

    val rCtrMemByt   = RegEnable(io.iCtrMemByt,   SIGS_ZERO, wHandShakeLSU)
    val rCtrRegWrEn  = RegEnable(io.iCtrRegWrEn,  SIGS_ZERO, wHandShakeLSU)
    val rCtrRegWrSrc = RegEnable(io.iCtrRegWrSrc, SIGS_ZERO, wHandShakeLSU)
    val rGPRRdAddr   = RegEnable(io.iGPRRdAddr,   GPRS_ZERO, wHandShakeLSU)
    val rALUZero     = RegEnable(io.iALUZero,     false.B,   wHandShakeLSU)
    val rALUOut      = RegEnable(io.iALUOut,      DATA_ZERO, wHandShakeLSU)
    val rMemRdData   = RegEnable(io.iMemRdData,   DATA_ZERO, wHandShakeLSU)

    io.oCtrMemByt   := Mux(wHandShakeWBU, rCtrMemByt,   SIGS_ZERO)
    io.oCtrRegWrEn  := Mux(wHandShakeWBU, rCtrRegWrEn,  SIGS_ZERO)
    io.oCtrRegWrSrc := Mux(wHandShakeWBU, rCtrRegWrSrc, SIGS_ZERO)
    io.oGPRRdAddr   := Mux(wHandShakeWBU, rGPRRdAddr,   GPRS_ZERO)
    io.oALUZero     := Mux(wHandShakeWBU, rALUZero,     false.B)
    io.oALUOut      := Mux(wHandShakeWBU, rALUOut,      DATA_ZERO)
    io.oMemRdData   := Mux(wHandShakeWBU, rMemRdData,   DATA_ZERO)
}
