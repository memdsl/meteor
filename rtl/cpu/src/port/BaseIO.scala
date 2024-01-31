package cpu.port

import chisel3._
import chisel3.util._

import cpu.base._

class BaseIO extends Bundle with ConfigIO {
    val bPC   = Output(UInt(ADDR_WIDTH.W))
    val bInst = Output(UInt(DATA_WIDTH.W))
}
