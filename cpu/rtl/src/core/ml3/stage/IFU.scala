package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class IFU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrCPU     = Input(Bool())
        val iReadyFrIFU2IDU = Input(Bool())
        val iPCJmpEn        = Input(Bool())
        val iPCJmp          = Input(UInt())

        val oValidToIFU2IDU = Output(Bool())
        val oPC             = Output(UInt(ADDR_WIDTH.W))
        val oPCNext         = Output(UInt(ADDR_WIDTH.W))
    })

    io.oValidToIFU2IDU := true.B

    val rPC = RegInit(ADDR_INIT)
    rPC := Mux(io.iReadyFrCPU, rPC + 4.U(ADDR_WIDTH.W), rPC)

    val wPC     = Mux(io.iPCJmpEn, io.iPCJmp, rPC)
    val wPCNext = wPC + 4.U(ADDR_WIDTH.W)

    io.oPC     := Mux(io.oValidToIFU2IDU && io.iReadyFrIFU2IDU, wPC,     ADDR_ZERO)
    io.oPCNext := Mux(io.oValidToIFU2IDU && io.iReadyFrIFU2IDU, wPCNext, ADDR_ZERO)
}
