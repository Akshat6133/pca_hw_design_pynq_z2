# ========================
# Project configuration
# ========================

TOP       := top
RTL_DIR   := rtl
SIM_DIR   := sim
OBJ_DIR   := obj_dir
PCA_TOP   := pca_top
PCA_OBJ_DIR := obj_pca

RTL_SRCS := \
	$(RTL_DIR)/top.v \
	$(RTL_DIR)/adder.v \
	$(RTL_DIR)/fifo.v

PCA_RTL_SRCS := \
	$(RTL_DIR)/pca_top.sv

VERILATOR := verilator
GTKWAVE   := gtkwave
YOSYS     := yosys

# ========================
# Verilator flags
# ========================

VERILATOR_FLAGS := \
	-Wall \
	-Irtl \
	--top-module $(TOP) \
	--cc $(RTL_SRCS) \
	--exe $(SIM_DIR)/tb.cpp \
	--trace \
	--Mdir $(OBJ_DIR) \
	-O3 \
	--x-assign fast \
	--x-initial fast 
	#--coverage

#
# ========================
# Verilog Testbench 
# ========================

#VERILATOR_FLAGS := \
#	-Wall \
#	--top-module tb_top \
#	--cc $(RTL_SRCS) sim/tb_top.v \
#	--trace \
#	--Mdir $(OBJ_DIR)
#
# To run with the verilog testbench
##make
##./obj_dir/Vtb_top
##gtkwave dump.vcd

#
# ========================
# Targets
# ========================

.PHONY: all build run wave clean synth

all: build run

build:
	$(VERILATOR) $(VERILATOR_FLAGS) --build

run:
	./$(OBJ_DIR)/V$(TOP)

pca: build_pca run_pca

build_pca:
	$(VERILATOR) -Wall \
	--sv \
	-Irtl \
		--top-module $(PCA_TOP) \
		--cc $(PCA_RTL_SRCS) \
		--exe $(SIM_DIR)/tb_pca.cpp \
		--trace \
		--Mdir $(PCA_OBJ_DIR) \
		-O3 \
		--x-assign fast \
		--x-initial fast \
		--build

run_pca:
	./$(PCA_OBJ_DIR)/V$(PCA_TOP)

wave:
	$(GTKWAVE) dump.vcd

clean:
	rm -rf $(OBJ_DIR) $(PCA_OBJ_DIR) dump.vcd synth

# ========================
# Synthesis (Yosys)
# ========================

synth:
	mkdir -p synth
	$(YOSYS) -p \
	"read_verilog $(RTL_SRCS); \
	 synth -top $(TOP); \
	 stat" \
	| tee synth/report.txt
