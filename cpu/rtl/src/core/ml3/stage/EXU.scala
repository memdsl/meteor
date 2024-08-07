package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._
import cpu.calc._

class EXU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrIDU2EXU = Input(Bool())
        val iReadyFrEXU2LSU = Input(Bool())
        val iPC             = Input(UInt(ADDR_WIDTH.W))
        val iPCNext         = Input(UInt(ADDR_WIDTH.W))
        val iInst           = Input(UInt(INST_WIDTH.W))
        val oValidToIDU2EXU = Output(Bool())
        val oValidToEXU2LSU = Output(Bool())
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
        val iGPRRS2Data     = Input(UInt(DATA_WIDTH.W))
        val iALURS1Data     = Input(UInt(DATA_WIDTH.W))
        val iALURS2Data     = Input(UInt(DATA_WIDTH.W))
        val oCtrMemWrEn     = Output(Bool())
        val oCtrMemByt      = Output(UInt(SIGS_WIDTH.W))
        val oCtrRegWrEn     = Output(Bool())
        val oCtrRegWrSrc    = Output(UInt(SIGS_WIDTH.W))
        val oGPRRdAddr      = Output(UInt(GPRS_WIDTH.W))
        val oGPRRS2Data     = Output(UInt(DATA_WIDTH.W))
        val oALUZero        = Output(Bool())
        val oALUOut         = Output(UInt(DATA_WIDTH.W))
    })

    val wHandShakeIDU2EXU = io.oValidToIDU2EXU && io.iReadyFrIDU2EXU
    val wHandShakeEXU2LSU = io.oValidToEXU2LSU && io.iReadyFrEXU2LSU

    io.oValidToIDU2EXU := true.B
    io.oValidToEXU2LSU := true.B

    val wPC     = Mux(wHandShakeIDU2EXU, io.iPC,     ADDR_ZERO)
    val wPCNext = Mux(wHandShakeIDU2EXU, io.iPCNext, ADDR_ZERO)
    val wInst   = Mux(wHandShakeIDU2EXU, io.iInst,   INST_ZERO)

    io.oPC     := Mux(wHandShakeEXU2LSU, wPC,     ADDR_ZERO)
    io.oPCNext := Mux(wHandShakeEXU2LSU, wPCNext, ADDR_ZERO)
    io.oInst   := Mux(wHandShakeEXU2LSU, wInst,   INST_ZERO)

    val wCtrInstName = Mux(wHandShakeIDU2EXU, io.iCtrInstName, SIGS_ZERO)
    val wCtrALUType  = Mux(wHandShakeIDU2EXU, io.iCtrALUType , SIGS_ZERO)
    val wCtrALURS1   = Mux(wHandShakeIDU2EXU, io.iCtrALURS1  , SIGS_ZERO)
    val wCtrALURS2   = Mux(wHandShakeIDU2EXU, io.iCtrALURS2  , SIGS_ZERO)
    val wCtrJmpEn    = Mux(wHandShakeIDU2EXU, io.iCtrJmpEn   , SIGS_ZERO)
    val wCtrMemWrEn  = Mux(wHandShakeIDU2EXU, io.iCtrMemWrEn , SIGS_ZERO)
    val wCtrMemByt   = Mux(wHandShakeIDU2EXU, io.iCtrMemByt  , SIGS_ZERO)
    val wCtrRegWrEn  = Mux(wHandShakeIDU2EXU, io.iCtrRegWrEn , SIGS_ZERO)
    val wCtrRegWrSrc = Mux(wHandShakeIDU2EXU, io.iCtrRegWrSrc, SIGS_ZERO)
    val wGPRRdAddr   = Mux(wHandShakeIDU2EXU, io.iGPRRdAddr,   DATA_ZERO)
    val wGPRRS2Data  = Mux(wHandShakeIDU2EXU, io.iGPRRS2Data,  DATA_ZERO)

    io.oCtrMemWrEn  := Mux(wHandShakeEXU2LSU, wCtrMemWrEn,  SIGS_ZERO)
    io.oCtrMemByt   := Mux(wHandShakeEXU2LSU, wCtrMemByt,   SIGS_ZERO)
    io.oCtrRegWrEn  := Mux(wHandShakeEXU2LSU, wCtrRegWrEn,  SIGS_ZERO)
    io.oCtrRegWrSrc := Mux(wHandShakeEXU2LSU, wCtrRegWrSrc, SIGS_ZERO)
    io.oGPRRdAddr   := Mux(wHandShakeEXU2LSU, wGPRRdAddr,   GPRS_ZERO)
    io.oGPRRS2Data  := Mux(wHandShakeEXU2LSU, wGPRRS2Data,  DATA_ZERO)

    val wALURS1Data  = Mux(wHandShakeIDU2EXU, io.iALURS1Data , DATA_ZERO)
    val wALURS2Data  = Mux(wHandShakeIDU2EXU, io.iALURS2Data , DATA_ZERO)

    val mALU = Module(new ALU)
    mALU.io.iType    := wCtrALUType
    mALU.io.iRS1Data := wALURS1Data
    mALU.io.iRS2Data := wALURS2Data

    io.oALUZero := Mux(wHandShakeEXU2LSU, mALU.io.oZero, false.B)
    io.oALUOut  := Mux(wHandShakeEXU2LSU, mALU.io.oOut,  DATA_ZERO)
}
