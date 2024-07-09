package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class IFU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrCPU = Input(Bool())
        val iReadyFrIFU = Input(Bool())
        val iPCJumpEn   = Input(Bool())
        val iPCJump     = Input(UInt())

        val oValidToIFU = Output(Bool())
        val oPC         = Output(UInt(ADDR_WIDTH.W))
        val oPCNext     = Output(UInt(ADDR_WIDTH.W))
    })

    io.oValidToIFU := true.B

    val rPC = RegInit(ADDR_INIT)
    rPC := Mux(io.iReadyFrCPU, rPC + 4.U(ADDR_WIDTH.W), rPC)

    val wPC     = Mux(io.iPCJumpEn, io.iPCJump, rPC)
    val wPCNext = wPC + 4.U(ADDR_WIDTH.W)

    io.oPC     := Mux(io.oValidToIFU && io.iReadyFrIFU, wPC,     ADDR_INIT)
    io.oPCNext := Mux(io.oValidToIFU && io.iReadyFrIFU, wPCNext, ADDR_INIT)
}
