package cpu.port.ml2

import chisel3._
import chisel3.util._

import cpu.base._

class TraceIO extends Bundle with ConfigIO {
    val pCTR = new CTRIO
    val pIDU = new IDUIO
    val pEXU = new EXUIO
    val pLSU = new LSUIO
    val pWBU = new WBUIO
}
