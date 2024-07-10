package cpu.core.ml3

import chisel3._
import chisel3.util._

import cpu.base._

class Top extends Module with ConfigInst {
    val mIFU     = Module(new IFU)
    val mIDU     = Module(new IDU)
    val mEXU     = Module(new EXU)
    val mLSU     = Module(new LSU)
    val mWBU     = Module(new WBU)
    val mIFU2IDU = Module(new IFU2IDU)
    val mIDU2EXU = Module(new IDU2EXU)
    val mEXU2LSU = Module(new EXU2LSU)
    val mLSU2WBU = Module(new LSU2WBU)

    mIFU.io.iReadyFrCPU     := true.B
    mIFU.io.iReadyFrIFU2IDU := mIFU2IDU.io.oValidToIFU
    mIFU.io.iPCJmpEn        := false.B
    mIFU.io.iPCJmp          := ADDR_ZERO

    mIFU2IDU.io.iReadyFrIFU := mIFU.io.oValidToIFU2IDU
    mIFU2IDU.io.iReadyFrIDU := mIDU.io.oValidToIFU2IDU
    mIFU2IDU.io.iPC         := mIFU.io.oPC
    mIFU2IDU.io.iPCNext     := mIFU.io.oPCNext

    mIDU.io.iReadyFrIFU2IDU := mIFU2IDU.io.oValidToIDU
    mIDU.io.iReadyFrIDU2EXU := mIDU2EXU.io.oValidToIDU
    mIDU.io.iPC             := mIFU2IDU.io.oPC
    mIDU.io.iPCNext         := mIFU2IDU.io.oPCNext
    mIDU.io.iInst           := 0.U
    mIDU.io.iGPRRS1Data     := 0.U
    mIDU.io.iGPRRS2Data     := 0.U

    mIDU2EXU.io.iReadyFrIDU  := mIDU.io.oValidToIDU2EXU
    mIDU2EXU.io.iReadyFrEXU  := mEXU.io.oValidToIDU2EXU
    mIDU2EXU.io.iPC          := mIDU.io.oPC
    mIDU2EXU.io.iPCNext      := mIDU.io.oPCNext
    mIDU2EXU.io.iInst        := mIDU.io.oInst
    mIDU2EXU.io.iCtrInstName := mIDU.io.oCtrInstName
    mIDU2EXU.io.iCtrALUType  := mIDU.io.oCtrALUType
    mIDU2EXU.io.iCtrALURS1   := mIDU.io.oCtrALURS1
    mIDU2EXU.io.iCtrALURS2   := mIDU.io.oCtrALURS2
    mIDU2EXU.io.iCtrJmpEn    := mIDU.io.oCtrJmpEn
    mIDU2EXU.io.iCtrMemWrEn  := mIDU.io.oCtrMemWrEn
    mIDU2EXU.io.iCtrMemByt   := mIDU.io.oCtrMemByt
    mIDU2EXU.io.iCtrRegWrEn  := mIDU.io.oCtrRegWrEn
    mIDU2EXU.io.iCtrRegWrSrc := mIDU.io.oCtrRegWrSrc
    mIDU2EXU.io.iGPRRdAddr   := mIDU.io.oGPRRdAddr
    mIDU2EXU.io.iGPRRS2Data  := mIDU.io.oGPRRS2Data
    mIDU2EXU.io.iALURS1Data  := mIDU.io.oALURS1Data
    mIDU2EXU.io.iALURS2Data  := mIDU.io.oALURS2Data

    mEXU.io.iReadyFrIDU2EXU := mIDU2EXU.io.oValidToEXU
    mEXU.io.iReadyFrEXU2LSU := mEXU2LSU.io.oValidToEXU
    mEXU.io.iPC             := mIDU2EXU.io.oPC
    mEXU.io.iPCNext         := mIDU2EXU.io.oPCNext
    mEXU.io.iInst           := mIDU2EXU.io.oInst
    mEXU.io.iCtrInstName    := mIDU2EXU.io.oCtrInstName
    mEXU.io.iCtrALUType     := mIDU2EXU.io.oCtrALUType
    mEXU.io.iCtrALURS1      := mIDU2EXU.io.oCtrALURS1
    mEXU.io.iCtrALURS2      := mIDU2EXU.io.oCtrALURS2
    mEXU.io.iCtrJmpEn       := mIDU2EXU.io.oCtrJmpEn
    mEXU.io.iCtrMemWrEn     := mIDU2EXU.io.oCtrMemWrEn
    mEXU.io.iCtrMemByt      := mIDU2EXU.io.oCtrMemByt
    mEXU.io.iCtrRegWrEn     := mIDU2EXU.io.oCtrRegWrEn
    mEXU.io.iCtrRegWrSrc    := mIDU2EXU.io.oCtrRegWrSrc
    mEXU.io.iGPRRdAddr      := mIDU2EXU.io.oGPRRdAddr
    mEXU.io.iGPRRS2Data     := mIDU2EXU.io.oGPRRS2Data
    mEXU.io.iALURS1Data     := mIDU2EXU.io.oALURS1Data
    mEXU.io.iALURS2Data     := mIDU2EXU.io.oALURS2Data

    mEXU2LSU.io.iReadyFrEXU  := mEXU.io.oValidToEXU2LSU
    mEXU2LSU.io.iReadyFrLSU  := mLSU.io.oValidToEXU2LSU
    mEXU2LSU.io.iPC          := mEXU.io.oPC
    mEXU2LSU.io.iPCNext      := mEXU.io.oPCNext
    mEXU2LSU.io.iInst        := mEXU.io.oInst
    mEXU2LSU.io.iCtrMemWrEn  := mEXU.io.oCtrMemWrEn
    mEXU2LSU.io.iCtrMemByt   := mEXU.io.oCtrMemByt
    mEXU2LSU.io.iCtrRegWrEn  := mEXU.io.oCtrRegWrEn
    mEXU2LSU.io.iCtrRegWrSrc := mEXU.io.oCtrRegWrSrc
    mEXU2LSU.io.iGPRRdAddr   := mEXU.io.oGPRRdAddr
    mEXU2LSU.io.iGPRRS2Data  := mEXU.io.oGPRRS2Data
    mEXU2LSU.io.iALUZero     := mEXU.io.oALUZero
    mEXU2LSU.io.iALUOut      := mEXU.io.oALUOut

    mLSU.io.iReadyFrEXU2LSU := mEXU2LSU.io.oValidToLSU
    mLSU.io.iReadyFrLSU2WBU := mLSU2WBU.io.oValidToLSU
    mLSU.io.iPC             := mEXU2LSU.io.oPC
    mLSU.io.iPCNext         := mEXU2LSU.io.oPCNext
    mLSU.io.iInst           := mEXU2LSU.io.oInst
    mLSU.io.iCtrMemWrEn     := mEXU2LSU.io.oCtrMemWrEn
    mLSU.io.iCtrMemByt      := mEXU2LSU.io.oCtrMemByt
    mLSU.io.iCtrRegWrEn     := mEXU2LSU.io.oCtrRegWrEn
    mLSU.io.iCtrRegWrSrc    := mEXU2LSU.io.oCtrRegWrSrc
    mLSU.io.iGPRRdAddr      := mEXU2LSU.io.oGPRRdAddr
    mLSU.io.iGPRRS2Data     := mEXU2LSU.io.oGPRRS2Data
    mLSU.io.iALUZero        := mEXU2LSU.io.oALUZero
    mLSU.io.iALUOut         := mEXU2LSU.io.oALUOut
    mLSU.io.iMemRdData      := 0.U

    mLSU2WBU.io.iReadyFrLSU  := mLSU.io.oValidToLSU2WBU
    mLSU2WBU.io.iReadyFrWBU  := mWBU.io.oValidToLSU2WBU
    mLSU2WBU.io.iPC          := mLSU.io.oPC
    mLSU2WBU.io.iPCNext      := mLSU.io.oPCNext
    mLSU2WBU.io.iInst        := mLSU.io.oInst
    mLSU2WBU.io.iCtrMemByt   := mLSU.io.oCtrMemByt
    mLSU2WBU.io.iCtrRegWrEn  := mLSU.io.oCtrRegWrEn
    mLSU2WBU.io.iCtrRegWrSrc := mLSU.io.oCtrRegWrSrc
    mLSU2WBU.io.iGPRRdAddr   := mLSU.io.oGPRRdAddr
    mLSU2WBU.io.iALUZero     := mLSU.io.oALUZero
    mLSU2WBU.io.iALUOut      := mLSU.io.oALUOut
    mLSU2WBU.io.iMemRdData   := mLSU.io.oMemRdData

    mWBU.io.iReadyFrLSU2WBU := mLSU2WBU.io.oValidToWBU
    mWBU.io.iReadyFrCPU     := true.B
    mWBU.io.iPC             := mLSU2WBU.io.oPC
    mWBU.io.iPCNext         := mLSU2WBU.io.oPCNext
    mWBU.io.iInst           := mLSU2WBU.io.oInst
    mWBU.io.iCtrMemByt      := mLSU2WBU.io.oCtrMemByt
    mWBU.io.iCtrRegWrEn     := mLSU2WBU.io.oCtrRegWrEn
    mWBU.io.iCtrRegWrSrc    := mLSU2WBU.io.oCtrRegWrSrc
    mWBU.io.iGPRRdAddr      := mLSU2WBU.io.oGPRRdAddr
    mWBU.io.iALUZero        := mLSU2WBU.io.oALUZero
    mWBU.io.iALUOut         := mLSU2WBU.io.oALUOut
    mWBU.io.iMemRdData      := mLSU2WBU.io.oMemRdData

    dontTouch(mIFU.io)
    dontTouch(mIDU.io)
    dontTouch(mEXU.io)
    dontTouch(mLSU.io)
    dontTouch(mWBU.io)
    dontTouch(mIFU2IDU.io)
    dontTouch(mIDU2EXU.io)
    dontTouch(mEXU2LSU.io)
    dontTouch(mLSU2WBU.io)
}
