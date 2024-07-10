package cpu.base

import chisel3._
import chisel3.util._

import cpu.port._

class CSR extends Module with ConfigInst {
    val io = IO(new Bundle {
        val pCSRRd =         new CSRRdIO
        val pCSRWr = Flipped(new CSRWrIO)
    })

    val mCSR = Mem(CSRS_NUM, UInt(DATA_WIDTH.W))

    when (reset.asBool) {
        mCSR(CSRS_MSTATUS) := CSRS_MSTATUS_INIT
    }

    io.pCSRRd.bRdData     := mCSR(io.pCSRRd.bRdAddr)
    io.pCSRRd.bRdMSTAData := mCSR(CSRS_MSTATUS)
    io.pCSRRd.bRdMTVEData := mCSR(CSRS_MTVEC)
    io.pCSRRd.bRdMEPCData := mCSR(CSRS_MEPC)
    io.pCSRRd.bRdMCAUData := mCSR(CSRS_MCAUSE)

    when (io.pCSRWr.bWrEn) {
        mCSR(io.pCSRWr.bWrAddr) := io.pCSRWr.bWrData
    }

    when (io.pCSRWr.bWrMEn) {
        mCSR(CSRS_MEPC)   := io.pCSRWr.bWrMEPCData
        mCSR(CSRS_MCAUSE) := io.pCSRWr.bWrMCAUData
    }
}
