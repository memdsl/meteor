package cpu.calc

import chisel3._
import chisel3.util._

import cpu.base._

class ALU extends Module with ConfigInst {
    val io = IO(new Bundle {
        val iType    = Input(UInt(SIGS_WIDTH.W))
        val iRS1Data = Input(UInt(DATA_WIDTH.W))
        val iRS2Data = Input(UInt(DATA_WIDTH.W))

        val oZero    = Output(Bool())
        val oOut     = Output(UInt(DATA_WIDTH.W))
    })

    val jalrMask = Cat(Fill(DATA_WIDTH - 1, 1.U(1.W)), 0.U(1.W))
    val wOut = MuxLookup(io.iType, DATA_ZERO) (
        Seq(
            ALU_TYPE_SLL    ->  (io.iRS1Data << io.iRS2Data(4, 0)),
            ALU_TYPE_SRL    ->  (io.iRS1Data >> io.iRS2Data(4, 0)),
            ALU_TYPE_SRA    ->  (io.iRS1Data.asSInt >> io.iRS2Data(4, 0).asUInt).asUInt,
            ALU_TYPE_ADD    ->  (io.iRS1Data + io.iRS2Data),
            ALU_TYPE_SUB    ->  (io.iRS1Data - io.iRS2Data),
            ALU_TYPE_XOR    ->  (io.iRS1Data ^ io.iRS2Data),
            ALU_TYPE_OR     ->  (io.iRS1Data | io.iRS2Data),
            ALU_TYPE_AND    ->  (io.iRS1Data & io.iRS2Data),
            ALU_TYPE_SLT    ->  (io.iRS1Data.asSInt < io.iRS2Data.asSInt).asUInt,
            ALU_TYPE_SLTU   ->  (io.iRS1Data.asUInt < io.iRS2Data.asUInt).asUInt,
            ALU_TYPE_BEQ    ->  (io.iRS1Data === io.iRS2Data),
            ALU_TYPE_BNE    ->  (io.iRS1Data =/= io.iRS2Data),
            ALU_TYPE_BLT    ->  (io.iRS1Data.asSInt  < io.iRS2Data.asSInt).asUInt,
            ALU_TYPE_BGE    ->  (io.iRS1Data.asSInt >= io.iRS2Data.asSInt).asUInt,
            ALU_TYPE_BLTU   ->  (io.iRS1Data < io.iRS2Data),
            ALU_TYPE_BGEU   ->  (io.iRS1Data >= io.iRS2Data),
            ALU_TYPE_JALR   -> ((io.iRS1Data + io.iRS2Data) & jalrMask),
            ALU_TYPE_MUL    ->  (io.iRS1Data * io.iRS2Data),
            ALU_TYPE_MULH   -> ((io.iRS1Data.asSInt * io.iRS2Data.asSInt) >> DATA_WIDTH).asUInt,
            ALU_TYPE_MULHSU -> ((io.iRS1Data.asSInt * io.iRS2Data.asUInt) >> DATA_WIDTH).asUInt,
            ALU_TYPE_MULHU  -> ((io.iRS1Data.asUInt * io.iRS2Data.asUInt) >> DATA_WIDTH).asUInt,
            ALU_TYPE_DIV    ->  (io.iRS1Data.asSInt / io.iRS2Data.asSInt).asUInt,
            ALU_TYPE_DIVU   ->  (io.iRS1Data.asUInt / io.iRS2Data.asUInt).asUInt,
            ALU_TYPE_REM    ->  (io.iRS1Data.asSInt % io.iRS2Data.asSInt).asUInt,
            ALU_TYPE_REMU   ->  (io.iRS1Data.asUInt % io.iRS2Data.asUInt).asUInt,
        )
    )

    dontTouch(wOut)

    io.oZero := Mux(wOut === DATA_ZERO, 0.U, 1.U)
    io.oOut  := wOut
}
