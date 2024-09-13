#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vifu_tb.h"

int main(int argc, char **argv) {
    // VerilatedContext *contextp = new VerilatedContext;
    // contextp->commandArgs(argc, argv);
    // Vifu_tb *ifup = new Vifu_tb{ contextp };

    // VerilatedVcdC *tfp = new VerilatedVcdC;
    // contextp->traceEverOn(true);
    // // ifup->trace(tfp, 0);
    // // tfp->open("wave.vcd");

    // delete ifup;
    // // tfp->close();
    // delete contextp;
    // return 0;

    VerilatedContext *m_contextp = new VerilatedContext;
    VerilatedVcdC    *m_tracep   = new VerilatedVcdC;
    Vifu_tb          *m_duvp     = new Vifu_tb;

    m_contextp->traceEverOn(true);
    m_duvp->trace(m_tracep, 3);
    m_tracep->open("ifu_tb.vcd");

    while (!m_contextp->gotFinish()) {
        m_duvp->eval();
        m_tracep->dump(m_contextp->time());
        m_contextp->timeInc(1);
    }

    m_tracep->close();

    delete m_duvp;
    return 0;
}
