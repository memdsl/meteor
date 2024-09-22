#include <verilated.h>
#include <verilated_vcd_c.h>
#include "sim.h"

#include VTOP_H

int main(int argc, char **argv) {
    VerilatedContext *p_ctxt = new VerilatedContext;
    VerilatedVcdC    *p_wave = new VerilatedVcdC;
    VTOP             *p_vtop = new VTOP;

    p_ctxt->traceEverOn(true);
    p_vtop->trace(p_wave, 3);
    p_wave->open(TOP_W);

    while (!p_ctxt->gotFinish()) {
        p_vtop->eval();
        p_wave->dump(p_ctxt->time());
        p_ctxt->timeInc(1);
    }

    p_wave->close();

    delete p_vtop;
    return 0;
}
