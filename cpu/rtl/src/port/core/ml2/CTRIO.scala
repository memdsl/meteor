package cpu.port.ml2

import chisel3._
import chisel3.util._

import cpu.base._

class CTRIO extends Bundle with ConfigIO {
    val oInstName    = Output(UInt(SIGS_WIDTH.W))
    val oStateCurr   = Output(UInt(SIGS_WIDTH.W))
    val oPCWrEn      = Output(Bool())
    val oPCWrSrc     = Output(UInt(SIGS_WIDTH.W))
    val oPCNextEn    = Output(Bool())
    val oPCJumpEn    = Output(Bool())
    val oMemRdInstEn = Output(Bool())
    val oMemRdLoadEn = Output(Bool())
    val oMemRdSrc    = Output(UInt(SIGS_WIDTH.W))
    val oMemWrEn     = Output(Bool())
    val oMemByt      = Output(UInt(SIGS_WIDTH.W))
    val oIRWrEn      = Output(Bool())
    val oGPRWrEn     = Output(Bool())
    val oGPRWrSrc    = Output(UInt(SIGS_WIDTH.W))
    val oALUType     = Output(UInt(SIGS_WIDTH.W))
    val oALURS1      = Output(UInt(SIGS_WIDTH.W))
    val oALURS2      = Output(UInt(SIGS_WIDTH.W))
    val oEndPreFlag  = Output(Bool())
}
