package cpu.port.ml2

import chisel3._
import chisel3.util._

import cpu.base._

class IDUIO extends Bundle with ConfigIO {
    val oRS1Addr = Output(UInt(GPRS_WIDTH.W))
    val oRS2Addr = Output(UInt(GPRS_WIDTH.W))
    val oRDAddr  = Output(UInt(GPRS_WIDTH.W))
    val oRS1Data = Output(UInt(DATA_WIDTH.W))
    val oRS2Data = Output(UInt(DATA_WIDTH.W))
    val oEndData = Output(UInt(DATA_WIDTH.W))
    val oImmData = Output(UInt(DATA_WIDTH.W))
}
