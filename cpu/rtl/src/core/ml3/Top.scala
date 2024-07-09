package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class Top extends Module with ConfigInst {
    val mIFU     = Module(new IFU)
    val mIFU2IDU = Module(new IFU2IDU)

    mIFU.io.iReadyFrCPU := true.B
    mIFU.io.iReadyFrIFU := mIFU2IDU.io.oValidToIFU
    mIFU.io.iPCJumpEn   := false.B
    mIFU.io.iPCJump     := ADDR_INIT

    mIFU2IDU.io.iReadyFrIFU := mIFU.io.oValidToIFU
    mIFU2IDU.io.iReadyFrIDU := true.B
    mIFU2IDU.io.iPC         := mIFU.io.oPC
    mIFU2IDU.io.iPCNext     := mIFU.io.oPCNext

    dontTouch(mIFU.io)
    dontTouch(mIFU2IDU.io)
}
