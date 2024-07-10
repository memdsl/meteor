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

    })

    io.oValidToEXU := true.B
    io.oValidToLSU := true.B

    val rPC     = RegEnable(io.iPC,     ADDR_INIT, io.oValidToEXU && io.iReadyFrEXU)
    val rPCNext = RegEnable(io.iPCNext, ADDR_INIT, io.oValidToEXU && io.iReadyFrEXU)
    val rInst   = RegEnable(io.iInst,   INST_ZERO, io.oValidToEXU && io.iReadyFrEXU)

    io.oPC     := Mux(io.oValidToLSU && io.iReadyFrLSU, rPC,     ADDR_ZERO)
    io.oPCNext := Mux(io.oValidToLSU && io.iReadyFrLSU, rPCNext, ADDR_ZERO)
    io.oInst   := Mux(io.oValidToLSU && io.iReadyFrLSU, rInst,   INST_ZERO)


}
