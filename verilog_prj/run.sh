#verilator -Wall --cc top.v --exe tb.cpp --trace
#make -C obj_dir -j
#./obj_dir/Vtop
#gtkwave dump.vcd

#!/bin/bash
set -e

verilator -Wall --cc top.v --exe tb.cpp --trace --build
./obj_dir/Vtop
gtkwave dump.vcd

