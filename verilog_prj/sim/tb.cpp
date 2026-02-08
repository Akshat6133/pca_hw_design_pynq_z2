
#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

vluint64_t sim_time = 0;

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vtop *dut = new Vtop;

    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("dump.vcd");

    dut->rst_n = 0;
    dut->clk   = 0;

    // Reset cycles
    for (int i = 0; i < 5; i++) {
        dut->clk ^= 1;
        dut->eval();
        tfp->dump(sim_time++);
    }

    dut->rst_n = 1;

    // Run
    for (int i = 0; i < 200; i++) {
        dut->clk ^= 1;
        dut->eval();
        tfp->dump(sim_time++);
    }

    tfp->close();
    delete dut;
    return 0;
}
