package cpu.mem

import chisel3._
import chisel3.util._

import cpu.base._
import cpu.port._

class MemDualFakeBB extends BlackBox {
    val io = IO(new Bundle {
        val pMemInst = new MemDualInstIO
        val pMemData = new MemDualDataIO
    })
}
