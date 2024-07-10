package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class WBU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrLSU2WBU = Input(Bool())
        val iReadyFrCPU     = Input(Bool())
        val iPC             = Input(UInt(ADDR_WIDTH.W))
        val iPCNext         = Input(UInt(ADDR_WIDTH.W))
        val iInst           = Input(UInt(INST_WIDTH.W))
        val oValidToLSU2WBU = Output(Bool())
        val oValidToCPU     = Output(Bool())
        val oPC             = Output(UInt(ADDR_WIDTH.W))
        val oPCNext         = Output(UInt(ADDR_WIDTH.W))
        val oInst           = Output(UInt(INST_WIDTH.W))

        val iCtrMemByt      = Input(UInt(SIGS_WIDTH.W))
        val iCtrRegWrEn     = Input(Bool())
        val iCtrRegWrSrc    = Input(UInt(SIGS_WIDTH.W))
        val iGPRRdAddr      = Input(UInt(GPRS_WIDTH.W))
        val iALUZero        = Input(Bool())
        val iALUOut         = Input(UInt(DATA_WIDTH.W))
        val iMemRdData      = Input(UInt(DATA_WIDTH.W))

        val oGPRWrEn   = Output(Bool())
        val oGPRWrAddr = Output(UInt(GPRS_WIDTH.W))
        val oGPRWrData = Output(UInt(DATA_WIDTH.W))
    })

    val wHandShakeLSU2WBU = io.oValidToLSU2WBU && io.iReadyFrLSU2WBU
    val wHandShakeCPU     = io.oValidToCPU     && io.iReadyFrCPU

    io.oValidToLSU2WBU := true.B
    io.oValidToCPU     := true.B

    val wPC     = Mux(wHandShakeLSU2WBU, io.iPC,     ADDR_ZERO)
    val wPCNext = Mux(wHandShakeLSU2WBU, io.iPCNext, ADDR_ZERO)
    val wInst   = Mux(wHandShakeLSU2WBU, io.iInst,   INST_ZERO)

    io.oPC     := Mux(wHandShakeCPU, wPC,     ADDR_ZERO)
    io.oPCNext := Mux(wHandShakeCPU, wPCNext, ADDR_ZERO)
    io.oInst   := Mux(wHandShakeCPU, wInst,   INST_ZERO)

    val wCtrMemByt   = Mux(wHandShakeLSU2WBU, io.iCtrMemByt,   SIGS_ZERO)
    val wCtrRegWrEn  = Mux(wHandShakeLSU2WBU, io.iCtrRegWrEn,  SIGS_ZERO)
    val wCtrRegWrSrc = Mux(wHandShakeLSU2WBU, io.iCtrRegWrSrc, SIGS_ZERO)
    val wGPRRdAddr   = Mux(wHandShakeLSU2WBU, io.iGPRRdAddr,   GPRS_ZERO)
    val wALUZero     = Mux(wHandShakeLSU2WBU, io.iALUZero,     false.B)
    val wALUOut      = Mux(wHandShakeLSU2WBU, io.iALUOut,      DATA_ZERO)
    val wMemRdData   = Mux(wHandShakeLSU2WBU, io.iMemRdData,   DATA_ZERO)


    val wGPRWrData = MuxLookup(wCtrRegWrSrc, DATA_ZERO) (
        Seq(
            REG_WR_SRC_ALU -> wALUOut,
            REG_WR_SRC_PC  -> wPCNext
        )
    )
    when (wHandShakeCPU && (wCtrRegWrEn === REG_WR_TR)) {
        io.oGPRWrEn   := true.B
        io.oGPRWrAddr := wGPRRdAddr
        when (wCtrRegWrSrc === REG_WR_SRC_MEM) {
            val wMemRdDataByt1 = wMemRdData(BYTE_WIDTH * 1 - 1, 0)
            val wMemRdDataByt2 = wMemRdData(BYTE_WIDTH * 2 - 1, 0)
            val wMemRdDataByt4 = wMemRdData(BYTE_WIDTH * 4 - 1, 0)
            val wMemRdDataByt  = MuxLookup(wCtrMemByt, DATA_ZERO) (
                Seq(
                    MEM_BYT_1_S ->
                        ExtenSign(wMemRdDataByt1, DATA_WIDTH),
                    MEM_BYT_1_U ->
                        ExtenZero(wMemRdDataByt1, DATA_WIDTH),
                    MEM_BYT_2_S ->
                        ExtenSign(wMemRdDataByt2, DATA_WIDTH),
                    MEM_BYT_2_U ->
                        ExtenZero(wMemRdDataByt2, DATA_WIDTH),
                    MEM_BYT_4_S ->
                        ExtenSign(wMemRdDataByt4, DATA_WIDTH),
                    MEM_BYT_4_U ->
                        ExtenZero(wMemRdDataByt4, DATA_WIDTH)
                )
            )
            io.oGPRWrData := wMemRdDataByt
        }
        .otherwise {
            io.oGPRWrData := wGPRWrData
        }
    }
    .otherwise {
        io.oGPRWrEn   := false.B
        io.oGPRWrAddr := ADDR_ZERO
        io.oGPRWrData := DATA_ZERO
    }
}
