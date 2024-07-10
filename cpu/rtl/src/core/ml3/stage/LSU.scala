package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class LSU extends Module with ConfigInst {
    val io = IO(new Bundle{
        val iReadyFrEXU2LSU = Input(Bool())
        val iReadyFrLSU2WBU = Input(Bool())
        val iPC             = Input(UInt(ADDR_WIDTH.W))
        val iPCNext         = Input(UInt(ADDR_WIDTH.W))
        val iInst           = Input(UInt(INST_WIDTH.W))
        val oValidToEXU2LSU = Output(Bool())
        val oValidToLSU2WBU = Output(Bool())
        val oPC             = Output(UInt(ADDR_WIDTH.W))
        val oPCNext         = Output(UInt(ADDR_WIDTH.W))
        val oInst           = Output(UInt(INST_WIDTH.W))

        val iCtrMemWrEn     = Input(Bool())
        val iCtrMemByt      = Input(UInt(SIGS_WIDTH.W))
        val iCtrRegWrEn     = Input(Bool())
        val iCtrRegWrSrc    = Input(UInt(SIGS_WIDTH.W))
        val iGPRRdAddr      = Input(UInt(GPRS_WIDTH.W))
        val iALUZero        = Input(Bool())
        val iALUOut         = Input(UInt(DATA_WIDTH.W))
        val iMemRdData      = Input(UInt(DATA_WIDTH.W))

        val oCtrRegWrEn     = Output(Bool())
        val oCtrRegWrSrc    = Output(UInt(SIGS_WIDTH.W))
        val oMemRdEn        = Output(Bool())
        val oMemRdAddr      = Output(UInt(ADDR_WIDTH.W))
        val oMemRdData      = Output(UInt(DATA_WIDTH.W))
        val oMemWrEn        = Output(Bool())
        val oMemWrAddr      = Output(UInt(ADDR_WIDTH.W))
        val oMemWrData      = Output(UInt(DATA_WIDTH.W))
        val oMemWrMask      = Output(UInt(MASK_WIDTH.W))
    })

    val wHandShakeEXU2LSU = io.oValidToEXU2LSU && io.iReadyFrEXU2LSU
    val wHandShakeLSU2WBU = io.oValidToLSU2WBU && io.iReadyFrLSU2WBU

    io.oValidToEXU2LSU := true.B
    io.oValidToLSU2WBU := true.B

    val wPC     = Mux(wHandShakeEXU2LSU, io.iPC,     ADDR_ZERO)
    val wPCNext = Mux(wHandShakeEXU2LSU, io.iPCNext, ADDR_ZERO)
    val wInst   = Mux(wHandShakeEXU2LSU, io.iInst,   INST_ZERO)

    io.oPC     := Mux(wHandShakeLSU2WBU, wPC,     ADDR_ZERO)
    io.oPCNext := Mux(wHandShakeLSU2WBU, wPCNext, ADDR_ZERO)
    io.oInst   := Mux(wHandShakeLSU2WBU, wInst,   INST_ZERO)

    val wCtrMemWrEn  = Mux(wHandShakeEXU2LSU, io.iCtrMemWrEn,  SIGS_ZERO)
    val wCtrMemByt   = Mux(wHandShakeEXU2LSU, io.iCtrMemByt,   SIGS_ZERO)
    val wCtrRegWrEn  = Mux(wHandShakeEXU2LSU, io.iCtrRegWrEn,  SIGS_ZERO)
    val wCtrRegWrSrc = Mux(wHandShakeEXU2LSU, io.iCtrRegWrSrc, SIGS_ZERO)
    val wGPRRdAddr   = Mux(wHandShakeEXU2LSU, io.iGPRRdAddr,   GPRS_ZERO)
    val wALUZero     = Mux(wHandShakeEXU2LSU, io.iALUZero,     false.B)
    val wALUOut      = Mux(wHandShakeEXU2LSU, io.iALUOut,      DATA_ZERO)

    io.oCtrRegWrEn  := Mux(wHandShakeLSU2WBU, wCtrRegWrEn,  SIGS_ZERO)
    io.oCtrRegWrSrc := Mux(wHandShakeLSU2WBU, wCtrRegWrSrc, SIGS_ZERO)

    val wMemRdInst = !(wCtrMemWrEn.asBool) && (wCtrMemByt != MEM_BYT_X).asBool
    val wMemRdAddr = Mux(wHandShakeEXU2LSU && wMemRdInst, wALUOut, ADDR_ZERO)
    val wMemRdData = Mux(wHandShakeEXU2LSU, io.iMemRdData, DATA_ZERO)

    io.oMemRdEn   := true.B
    io.oMemRdAddr := wMemRdAddr
    io.oMemRdData := Mux(wHandShakeLSU2WBU, wMemRdData, DATA_ZERO)

    when (wHandShakeEXU2LSU && wCtrMemWrEn.asBool) {
        io.oMemWrEn   := true.B
        io.oMemWrAddr := wALUOut
        io.oMemWrData := 0.U
        io.oMemWrMask := MuxLookup(
            wCtrMemByt,
            VecInit(("b1111".U).asBools)) (
            Seq(
                MEM_BYT_1_U -> VecInit(false.B, false.B, false.B, true.B),
                MEM_BYT_2_U -> VecInit(false.B, false.B, true.B,  true.B),
                MEM_BYT_4_U -> VecInit(("b1111".U).asBools)
            )
        )
    }
    .otherwise {
        io.oMemWrEn   := false.B
        io.oMemWrAddr := ADDR_ZERO
        io.oMemWrData := ADDR_ZERO
        io.oMemWrMask := VecInit(("b1111".U).asBools)
    }


}
