package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class EXU2LSU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrEXU  = Input(Bool())
        val iReadyFrLSU  = Input(Bool())
        val iPC          = Input(UInt(ADDR_WIDTH.W))
        val iPCNext      = Input(UInt(ADDR_WIDTH.W))
        val iInst        = Input(UInt(INST_WIDTH.W))
        val oValidToEXU  = Output(Bool())
        val oValidToLSU  = Output(Bool())
        val oPC          = Output(UInt(ADDR_WIDTH.W))
        val oPCNext      = Output(UInt(ADDR_WIDTH.W))
        val oInst        = Output(UInt(INST_WIDTH.W))

        val iCtrMemWrEn  = Input(Bool())
        val iCtrMemByt   = Input(UInt(SIGS_WIDTH.W))
        val iCtrRegWrEn  = Input(Bool())
        val iCtrRegWrSrc = Input(UInt(SIGS_WIDTH.W))
        val iGPRRdAddr   = Input(UInt(GPRS_WIDTH.W))
        val iGPRRS2Data  = Input(UInt(GPRS_WIDTH.W))
        val iALUZero     = Input(Bool())
        val iALUOut      = Input(UInt(DATA_WIDTH.W))
        val oCtrMemWrEn  = Output(UInt(SIGS_WIDTH.W))
        val oCtrMemByt   = Output(UInt(SIGS_WIDTH.W))
        val oCtrRegWrEn  = Output(UInt(SIGS_WIDTH.W))
        val oCtrRegWrSrc = Output(UInt(SIGS_WIDTH.W))
        val oGPRRdAddr   = Output(UInt(SIGS_WIDTH.W))
        val oGPRRS2Data  = Output(UInt(DATA_WIDTH.W))
        val oALUZero     = Output(Bool())
        val oALUOut      = Output(UInt(DATA_WIDTH.W))
    })

    val wHandShakeEXU = io.oValidToEXU && io.iReadyFrEXU
    val wHandShakeLSU = io.oValidToLSU && io.iReadyFrLSU

    io.oValidToEXU := true.B
    io.oValidToLSU := true.B

    val rPC     = RegEnable(io.iPC,     ADDR_INIT, wHandShakeEXU)
    val rPCNext = RegEnable(io.iPCNext, ADDR_INIT, wHandShakeEXU)
    val rInst   = RegEnable(io.iInst,   INST_ZERO, wHandShakeEXU)

    io.oPC     := Mux(wHandShakeLSU, rPC,     ADDR_ZERO)
    io.oPCNext := Mux(wHandShakeLSU, rPCNext, ADDR_ZERO)
    io.oInst   := Mux(wHandShakeLSU, rInst,   INST_ZERO)

    val rCtrMemWrEn  = RegEnable(io.iCtrMemWrEn,  SIGS_ZERO, wHandShakeEXU)
    val rCtrMemByt   = RegEnable(io.iCtrMemByt,   SIGS_ZERO, wHandShakeEXU)
    val rCtrRegWrEn  = RegEnable(io.iCtrRegWrEn,  SIGS_ZERO, wHandShakeEXU)
    val rCtrRegWrSrc = RegEnable(io.iCtrRegWrSrc, SIGS_ZERO, wHandShakeEXU)
    val rGPRRdAddr   = RegEnable(io.iGPRRdAddr,   GPRS_ZERO, wHandShakeEXU)
    val rGPRRS2Data  = RegEnable(io.iGPRRS2Data,  DATA_ZERO, wHandShakeEXU)
    val rALUZero     = RegEnable(io.iALUZero,     false.B,   wHandShakeEXU)
    val rALUOut      = RegEnable(io.iALUOut,      DATA_ZERO, wHandShakeEXU)

    io.oCtrMemWrEn  := Mux(wHandShakeLSU, rCtrMemWrEn,  SIGS_ZERO)
    io.oCtrMemByt   := Mux(wHandShakeLSU, rCtrMemByt,   SIGS_ZERO)
    io.oCtrRegWrEn  := Mux(wHandShakeLSU, rCtrRegWrEn,  SIGS_ZERO)
    io.oCtrRegWrSrc := Mux(wHandShakeLSU, rCtrRegWrSrc, SIGS_ZERO)
    io.oGPRRdAddr   := Mux(wHandShakeLSU, rGPRRdAddr,   SIGS_ZERO)
    io.oGPRRS2Data  := Mux(wHandShakeLSU, rGPRRS2Data,   DATA_ZERO)
    io.oALUZero     := Mux(wHandShakeLSU, rALUZero,     false.B)
    io.oALUOut      := Mux(wHandShakeLSU, rALUOut,      DATA_ZERO)
}
