

# # INCS_DIR = $(shell find ${METEOR_HOME}/src -type d -name "rtl")
# INCS_DIR = $(shell realpath ./rtl/l1/stage)
# INCS     = $(addprefix -I, $(INCS_DIR))

# run:
# 	mkdir -p build
# 	iverilog -g2005-sv -o build/${FILE} ${INCS} rtl/l1/stage/${FILE}.sv tb/l1/${FILE}_tb.sv
# 	vvp -n build/${FILE} -lxt2
# sim: run
# 	gtkwave build/${FILE}.vcd
# clean:
# 	rm -rf build


.PHONY: gen run sim clean

CFG_TOP = ifu_tb
CFG_CXX = g++-10
CFG_BIN = $(METEOR_HOME)/build/meteor
CFG_VCD = $(METEOR_HOME)/build/$(CFG_TOP).vcd

VERILATOR      = verilator
VERILATOR_ARGS = --cc                         \
                 --exe                        \
                 --Mdir build                 \
                 --MMD                        \
                 -o $(CFG_BIN)             \
                 --timing                     \
                 --top-module $(CFG_TOP) \
                 --trace

CFLAGS  = -std=c++20  \
          -fcoroutines
LDFLAGS =

INCS_SV  = -I$(METEOR_HOME)/rtl/base
INCS     =  $(INCS_SV)

SRCS_SV  = tb/l1/ifu_tb.sv rtl/core/l1/stage/ifu.sv
SRCS_CXX = sim/sim.cpp
SRCS     = $(SRCS_SV) $(SRCS_CXX)

TEST = V$(CFG_TOP).mk

$(TEST):
	$(VERILATOR) $(VERILATOR_ARGS)     \
	$(INCS) $(SRCS)                    \
	$(addprefix -CFLAGS ,  $(CFLAGS))  \
	$(addprefix -LDFLAGS , $(LDFLAGS))
gen: $(TEST)
	make -C build -f $(TEST) CXX=$(CFG_CXX)
run: gen
	cd build; $(CFG_BIN)
sim:
	gtkwave $(CFG_VCD)
clean:
	rm -rf build
