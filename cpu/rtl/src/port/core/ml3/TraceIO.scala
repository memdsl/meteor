package cpu.port.ml3

import chisel3._
import chisel3.util._

import cpu.base._
import cpu.port._

class TraceIO extends Bundle with ConfigIO {
    val pBase    =         new BaseIO
    val pGPRRd   =         new GPRRdIO
    val pMemInst = Flipped(new MemDualInstIO)
    val pMemData = Flipped(new MemDualDataIO)
}
