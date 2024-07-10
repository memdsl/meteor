package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class IFU2IDU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iReadyFrIFU = Input(Bool())
        val iReadyFrIDU = Input(Bool())
        val iPC         = Input(UInt(ADDR_WIDTH.W))
        val iPCNext     = Input(UInt(ADDR_WIDTH.W))
        val oValidToIFU = Output(Bool())
        val oValidToIDU = Output(Bool())
        val oPC         = Output(UInt(ADDR_WIDTH.W))
        val oPCNext     = Output(UInt(ADDR_WIDTH.W))
    })

    val wHandShakeIFU = io.oValidToIFU && io.iReadyFrIFU
    val wHandShakeIDU = io.oValidToIFU && io.iReadyFrIFU

    io.oValidToIFU := true.B
    io.oValidToIDU := true.B

    val rPC     = RegEnable(io.iPC,     ADDR_INIT, wHandShakeIFU)
    val rPCNext = RegEnable(io.iPCNext, ADDR_INIT, wHandShakeIFU)

    io.oPC     := Mux(wHandShakeIDU, rPC,     ADDR_ZERO)
    io.oPCNext := Mux(wHandShakeIDU, rPCNext, ADDR_ZERO)
}
