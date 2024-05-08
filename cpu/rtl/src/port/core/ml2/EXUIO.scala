package cpu.port.ml2

import chisel3._
import chisel3.util._

import cpu.base._

class EXUIO extends Bundle with ConfigIO {
    val oPCNext    = Output(UInt(ADDR_WIDTH.W))
    val oPCJump    = Output(UInt(ADDR_WIDTH.W))
    val oALUZero   = Output(Bool())
    val oALUOut    = Output(UInt(DATA_WIDTH.W))
    val oMemWrData = Output(UInt(DATA_WIDTH.W))
}
