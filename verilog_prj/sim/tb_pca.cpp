#include "Vpca_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cmath>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

static vluint64_t sim_time = 0;

static constexpr int D = 4;
static constexpr int K = 2;
static constexpr int FRAC = 12;

static constexpr int32_t MU[D] = {
    23934, 12524, 15393, 4912
};

static constexpr int32_t W[K][D] = {
    {1480, -346, 3509, 1468},
    {2689, 2991, -710, -309}
};

struct Sample {
    int32_t x[D];
};

static int16_t sat_round_q12(int64_t acc) {
    // EXACT match to RTL:
    // shifted = acc + (1 << (FRAC-1));
    // rounded = shifted >>> FRAC;

    int64_t shifted = acc + (1LL << (FRAC - 1));
    int64_t rounded = shifted >> FRAC;   // arithmetic shift

    if (rounded > 32767) return 32767;
    if (rounded < -32768) return -32768;
    return static_cast<int16_t>(rounded);
}



static std::vector<Sample> load_samples_or_default(const std::string& path) {
    std::ifstream in(path);
    std::vector<Sample> samples;

    if (in) {
        std::string line;
        while (std::getline(in, line)) {
            if (line.empty() || line[0] == '#') continue;
            std::istringstream iss(line);
            Sample s{};
            if (iss >> s.x[0] >> s.x[1] >> s.x[2] >> s.x[3]) {
                samples.push_back(s);
            }
        }
    }

    if (!samples.empty()) return samples;

    // Q4.12 encoded Iris-like features [sepal_len, sepal_wid, petal_len, petal_wid].
    return {
        {{20890, 14336, 5734, 819}},   // [5.10, 3.50, 1.40, 0.20]
        {{20070, 12288, 5734, 819}},   // [4.90, 3.00, 1.40, 0.20]
        {{25395, 13926, 22118, 9421}}, // [6.20, 3.40, 5.40, 2.30]
        {{24166, 12288, 20890, 7373}}, // [5.90, 3.00, 5.10, 1.80]
        {{24576, 9011, 16384, 4096}},  // [6.00, 2.20, 4.00, 1.00]
        {{22528, 10240, 16384, 5325}}  // [5.50, 2.50, 4.00, 1.30]
    };
}

static int16_t get_y(const Vpca_top* dut, int idx) {
    uint32_t raw = (dut->y_flat >> (idx * 16U)) & 0xFFFFU;
    return static_cast<int16_t>(raw);
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vpca_top* dut = new Vpca_top;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("dump.vcd");

    auto tick = [&]() {
        dut->clk = 0;
        dut->eval();
        tfp->dump(sim_time++);
        dut->clk = 1;
        dut->eval();
        tfp->dump(sim_time++);
    };

    auto samples = load_samples_or_default("sim/data/pca_iris_q12.txt");
    if (samples.empty()) {
        std::cerr << "No input samples found.\n";
        return 1;
    }

    dut->rst_n = 0;
    dut->in_valid = 0;
    dut->x_flat = 0;
    tick();
    tick();
    dut->rst_n = 1;
    tick();

    int errors = 0;
    std::cout << "Running " << samples.size() << " PCA samples\n";

    for (size_t i = 0; i < samples.size(); ++i) {
        uint64_t packed = 0;
        for (int d = 0; d < D; ++d) {
            packed |= (static_cast<uint64_t>(static_cast<uint16_t>(samples[i].x[d]))
                       << (d * 16U));
        }

        dut->x_flat = packed;
        dut->in_valid = 1;
        tick();
        dut->in_valid = 0;

        if (!dut->out_valid) {
            std::cerr << "ERROR: out_valid not asserted for sample " << i << "\n";
            errors++;
            tick();
            continue;
        }

        int16_t exp[K] = {0};
        for (int k = 0; k < K; ++k) {
            int64_t acc = 0;
            for (int d = 0; d < D; ++d) {
                int32_t centered = samples[i].x[d] - MU[d];
                acc += static_cast<int64_t>(centered) * static_cast<int64_t>(W[k][d]);
            }
            exp[k] = sat_round_q12(acc);
        }

        for (int k = 0; k < K; ++k) {
            int16_t got = get_y(dut, k);
            if (got != exp[k]) {
                std::cerr << "Mismatch sample " << i << " comp " << k
                          << " got=" << got << " exp=" << exp[k] << "\n";
                errors++;
            }
        }

        // Gap cycle before next sample.
        tick();
    }

    if (errors == 0) {
        std::cout << "PASS: PCA projection matched golden model.\n";
    } else {
        std::cout << "FAIL: mismatches=" << errors << "\n";
    }

    tfp->close();
    delete tfp;
    delete dut;
    return (errors == 0) ? 0 : 1;
}
