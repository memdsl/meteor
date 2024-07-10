package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class IDU2EXU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrIDU  = Input(Bool())
        val iReadyFrEXU  = Input(Bool())
        val iPC          = Input(UInt(ADDR_WIDTH.W))
        val iPCNext      = Input(UInt(ADDR_WIDTH.W))
        val iInst        = Input(UInt(INST_WIDTH.W))
        val oValidToIDU  = Output(Bool())
        val oValidToEXU  = Output(Bool())
        val oPC          = Output(UInt(ADDR_WIDTH.W))
        val oPCNext      = Output(UInt(ADDR_WIDTH.W))
        val oInst        = Output(UInt(INST_WIDTH.W))

        val iCtrInstName = Input(UInt(SIGS_WIDTH.W))
        val iCtrALUType  = Input(UInt(SIGS_WIDTH.W))
        val iCtrALURS1   = Input(UInt(SIGS_WIDTH.W))
        val iCtrALURS2   = Input(UInt(SIGS_WIDTH.W))
        val iCtrJmpEn    = Input(Bool())
        val iCtrMemWrEn  = Input(Bool())
        val iCtrMemByt   = Input(UInt(SIGS_WIDTH.W))
        val iCtrRegWrEn  = Input(Bool())
        val iCtrRegWrSrc = Input(UInt(SIGS_WIDTH.W))
        val iGPRRdAddr   = Input(UInt(GPRS_WIDTH.W))
        val iALURS1Data  = Input(UInt(DATA_WIDTH.W))
        val iALURS2Data  = Input(UInt(DATA_WIDTH.W))
        val oCtrInstName = Output(UInt(SIGS_WIDTH.W))
        val oCtrALUType  = Output(UInt(SIGS_WIDTH.W))
        val oCtrALURS1   = Output(UInt(SIGS_WIDTH.W))
        val oCtrALURS2   = Output(UInt(SIGS_WIDTH.W))
        val oCtrJmpEn    = Output(Bool())
        val oCtrMemWrEn  = Output(Bool())
        val oCtrMemByt   = Output(UInt(SIGS_WIDTH.W))
        val oCtrRegWrEn  = Output(Bool())
        val oCtrRegWrSrc = Output(UInt(SIGS_WIDTH.W))
        val oGPRRdAddr    = Output(UInt(GPRS_WIDTH.W))
        val oALURS1Data  = Output(UInt(DATA_WIDTH.W))
        val oALURS2Data  = Output(UInt(DATA_WIDTH.W))
    })

    val wHandShakeIDU = io.oValidToIDU && io.iReadyFrIDU
    val wHandShakeEXU = io.oValidToEXU && io.iReadyFrEXU

    io.oValidToIDU := true.B
    io.oValidToEXU := true.B

    val rPC     = RegEnable(io.iPC,     ADDR_INIT, wHandShakeIDU)
    val rPCNext = RegEnable(io.iPCNext, ADDR_INIT, wHandShakeIDU)
    val rInst   = RegEnable(io.iInst,   INST_ZERO, wHandShakeIDU)

    io.oPC     := Mux(wHandShakeEXU, rPC,     ADDR_ZERO)
    io.oPCNext := Mux(wHandShakeEXU, rPCNext, ADDR_ZERO)
    io.oInst   := Mux(wHandShakeEXU, rInst,   INST_ZERO)

    val rCtrInstName = RegEnable(io.iCtrInstName, SIGS_ZERO, wHandShakeIDU)
    val rCtrALUType  = RegEnable(io.iCtrALUType,  SIGS_ZERO, wHandShakeIDU)
    val rCtrALURS1   = RegEnable(io.iCtrALURS1,   SIGS_ZERO, wHandShakeIDU)
    val rCtrALURS2   = RegEnable(io.iCtrALURS2,   SIGS_ZERO, wHandShakeIDU)
    val rCtrJmpEn    = RegEnable(io.iCtrJmpEn,    SIGS_ZERO, wHandShakeIDU)
    val rCtrMemWrEn  = RegEnable(io.iCtrMemWrEn,  SIGS_ZERO, wHandShakeIDU)
    val rCtrMemByt   = RegEnable(io.iCtrMemByt,   SIGS_ZERO, wHandShakeIDU)
    val rCtrRegWrEn  = RegEnable(io.iCtrRegWrEn,  SIGS_ZERO, wHandShakeIDU)
    val rCtrRegWrSrc = RegEnable(io.iCtrRegWrSrc, SIGS_ZERO, wHandShakeIDU)
    val rALURS1Data  = RegEnable(io.iALURS1Data,  DATA_ZERO, wHandShakeIDU)
    val rALURS2Data  = RegEnable(io.iALURS2Data,  DATA_ZERO, wHandShakeIDU)
    val rGPRRdAddr   = RegEnable(io.iGPRRdAddr,   GPRS_ZERO, wHandShakeIDU)

    io.oCtrInstName := Mux(wHandShakeEXU, rCtrInstName, SIGS_ZERO)
    io.oCtrALUType  := Mux(wHandShakeEXU, rCtrALUType , SIGS_ZERO)
    io.oCtrALURS1   := Mux(wHandShakeEXU, rCtrALURS1  , SIGS_ZERO)
    io.oCtrALURS2   := Mux(wHandShakeEXU, rCtrALURS2  , SIGS_ZERO)
    io.oCtrJmpEn    := Mux(wHandShakeEXU, rCtrJmpEn   , SIGS_ZERO)
    io.oCtrMemWrEn  := Mux(wHandShakeEXU, rCtrMemWrEn , SIGS_ZERO)
    io.oCtrMemByt   := Mux(wHandShakeEXU, rCtrMemByt  , SIGS_ZERO)
    io.oCtrRegWrEn  := Mux(wHandShakeEXU, rCtrRegWrEn , SIGS_ZERO)
    io.oCtrRegWrSrc := Mux(wHandShakeEXU, rCtrRegWrSrc, SIGS_ZERO)
    io.oGPRRdAddr   := Mux(wHandShakeEXU, rGPRRdAddr,   GPRS_ZERO)
    io.oALURS1Data  := Mux(wHandShakeEXU, rALURS1Data , DATA_ZERO)
    io.oALURS2Data  := Mux(wHandShakeEXU, rALURS2Data , DATA_ZERO)
}
