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

    io.oValidToIDU := true.B
    io.oValidToEXU := true.B

    val rPC     = RegEnable(io.iPC,     ADDR_INIT, io.oValidToIDU && io.iReadyFrIDU)
    val rPCNext = RegEnable(io.iPCNext, ADDR_INIT, io.oValidToIDU && io.iReadyFrIDU)
    val rInst   = RegEnable(io.iInst,   INST_ZERO, io.oValidToIDU && io.iReadyFrIDU)

    io.oPC     := Mux(io.oValidToEXU && io.iReadyFrEXU, rPC,     ADDR_ZERO)
    io.oPCNext := Mux(io.oValidToEXU && io.iReadyFrEXU, rPCNext, ADDR_ZERO)
    io.oInst   := Mux(io.oValidToEXU && io.iReadyFrEXU, rInst,   INST_ZERO)

    val rCtrInstName = RegEnable(io.iCtrInstName, SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rCtrALUType  = RegEnable(io.iCtrALUType,  SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rCtrALURS1   = RegEnable(io.iCtrALURS1,   SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rCtrALURS2   = RegEnable(io.iCtrALURS2,   SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rCtrJmpEn    = RegEnable(io.iCtrJmpEn,    SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rCtrMemWrEn  = RegEnable(io.iCtrMemWrEn,  SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rCtrMemByt   = RegEnable(io.iCtrMemByt,   SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rCtrRegWrEn  = RegEnable(io.iCtrRegWrEn,  SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rCtrRegWrSrc = RegEnable(io.iCtrRegWrSrc, SIGS_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rALURS1Data  = RegEnable(io.iALURS1Data,  DATA_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rALURS2Data  = RegEnable(io.iALURS2Data,  DATA_ZERO, io.oValidToIDU && io.iReadyFrIDU)
    val rGPRRdAddr   = RegEnable(io.iGPRRdAddr,   GPRS_ZERO, io.oValidToIDU && io.iReadyFrIDU)

    io.oCtrInstName := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrInstName, SIGS_ZERO)
    io.oCtrALUType  := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrALUType , SIGS_ZERO)
    io.oCtrALURS1   := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrALURS1  , SIGS_ZERO)
    io.oCtrALURS2   := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrALURS2  , SIGS_ZERO)
    io.oCtrJmpEn    := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrJmpEn   , SIGS_ZERO)
    io.oCtrMemWrEn  := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrMemWrEn , SIGS_ZERO)
    io.oCtrMemByt   := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrMemByt  , SIGS_ZERO)
    io.oCtrRegWrEn  := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrRegWrEn , SIGS_ZERO)
    io.oCtrRegWrSrc := Mux(io.oValidToEXU && io.iReadyFrEXU, rCtrRegWrSrc, SIGS_ZERO)
    io.oGPRRdAddr   := Mux(io.oValidToEXU && io.iReadyFrEXU, rGPRRdAddr,   GPRS_ZERO)
    io.oALURS1Data  := Mux(io.oValidToEXU && io.iReadyFrEXU, rALURS1Data , DATA_ZERO)
    io.oALURS2Data  := Mux(io.oValidToEXU && io.iReadyFrEXU, rALURS2Data , DATA_ZERO)
}
