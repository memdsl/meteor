package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._
import cpu.calc._

class EXU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrIDU2EXU = Input(Bool())
        val iReadyFrEXU2WBU = Input(Bool())
        val iPC             = Input(UInt(ADDR_WIDTH.W))
        val iPCNext         = Input(UInt(ADDR_WIDTH.W))
        val iInst           = Input(UInt(INST_WIDTH.W))
        val oValidToIDU2EXU = Output(Bool())
        val oValidToEXU2WBU = Output(Bool())
        val oPC             = Output(UInt(ADDR_WIDTH.W))
        val oPCNext         = Output(UInt(ADDR_WIDTH.W))
        val oInst           = Output(UInt(INST_WIDTH.W))

        val iCtrInstName    = Input(UInt(SIGS_WIDTH.W))
        val iCtrALUType     = Input(UInt(SIGS_WIDTH.W))
        val iCtrALURS1      = Input(UInt(SIGS_WIDTH.W))
        val iCtrALURS2      = Input(UInt(SIGS_WIDTH.W))
        val iCtrJmpEn       = Input(Bool())
        val iCtrMemWrEn     = Input(Bool())
        val iCtrMemByt      = Input(UInt(SIGS_WIDTH.W))
        val iCtrRegWrEn     = Input(Bool())
        val iCtrRegWrSrc    = Input(UInt(SIGS_WIDTH.W))
        val iGPRRdAddr      = Input(UInt(GPRS_WIDTH.W))
        val iALURS1Data     = Input(UInt(DATA_WIDTH.W))
        val iALURS2Data     = Input(UInt(DATA_WIDTH.W))

        val oCtrMemWrEn     = Input(Bool())
        val oCtrMemByt      = Input(UInt(SIGS_WIDTH.W))
        val oCtrRegWrEn     = Input(Bool())
        val oCtrRegWrSrc    = Input(UInt(SIGS_WIDTH.W))
        val oGPRRdAddr      = Output(UInt(GPRS_WIDTH.W))
        val oALUZero        = Output(Bool())
        val oALUOut         = Output(UInt(DATA_WIDTH.W))
    })

    io.oValidToIDU2EXU := true.B
    io.oValidToEXU2WBU := true.B

    val wPC     = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iPC,     ADDR_ZERO)
    val wPCNext = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iPCNext, ADDR_ZERO)
    val wInst   = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iInst,   INST_ZERO)

    io.oPC     := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, wPC,     ADDR_ZERO)
    io.oPCNext := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, wPCNext, ADDR_ZERO)
    io.oInst   := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, wInst,   INST_ZERO)

    val wCtrInstName = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrInstName, SIGS_ZERO)
    val wCtrALUType  = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrALUType , SIGS_ZERO)
    val wCtrALURS1   = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrALURS1  , SIGS_ZERO)
    val wCtrALURS2   = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrALURS2  , SIGS_ZERO)
    val wCtrJmpEn    = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrJmpEn   , SIGS_ZERO)
    val wCtrMemWrEn  = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrMemWrEn , SIGS_ZERO)
    val wCtrMemByt   = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrMemByt  , SIGS_ZERO)
    val wCtrRegWrEn  = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrRegWrEn , SIGS_ZERO)
    val wCtrRegWrSrc = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iCtrRegWrSrc, SIGS_ZERO)
    val wGPRRdAddr   = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iGPRRdAddr,   DATA_ZERO)

    io.oCtrMemWrEn  := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, wCtrMemWrEn,  SIGS_ZERO)
    io.oCtrMemByt   := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, wCtrMemByt,   SIGS_ZERO)
    io.oCtrRegWrEn  := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, wCtrRegWrEn,  SIGS_ZERO)
    io.oCtrRegWrSrc := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, wCtrRegWrSrc, SIGS_ZERO)
    io.oGPRRdAddr   := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, wGPRRdAddr,   GPRS_ZERO)

    val wALURS1Data  = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iALURS1Data , DATA_ZERO)
    val wALURS2Data  = Mux(io.oValidToIDU2EXU && io.iReadyFrIDU2EXU, io.iALURS2Data , DATA_ZERO)

    val mALU = Module(new ALU)
    mALU.io.iType    := wCtrALUType
    mALU.io.iRS1Data := wALURS1Data
    mALU.io.iRS2Data := wALURS2Data

    io.oALUZero := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, mALU.io.oZero, false.B)
    io.oALUOut  := Mux(io.oValidToEXU2WBU && io.iReadyFrEXU2WBU, mALU.io.oOut,  DATA_ZERO)
}
