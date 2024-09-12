.PHONY: FILE_MK run sim clean

CFG_TOP = ifu_tb
CFG_CXX = g++-10
VERILATOR      = verilator
VERILATOR_ARGS = --cc                         \
                 --exe                        \
                 --Mdir build                 \
                 --MMD                        \
                 -o $(FILE_BIN)             \
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

FILE_MK  = V$(CFG_TOP).mk
FILE_BIN = $(METEOR_HOME)/build/meteor
FILE_VCD = $(METEOR_HOME)/build/$(CFG_TOP).vcd

$(FILE_MK):
	$(VERILATOR) $(VERILATOR_ARGS)     \
	$(INCS) $(SRCS)                    \
	$(addprefix -CFLAGS ,  $(CFLAGS))  \
	$(addprefix -LDFLAGS , $(LDFLAGS))
$(FILE_BIN): $(FILE_MK)
	make -C build -f $(FILE_MK) CXX=$(CFG_CXX)

run: $(FILE_BIN)
	cd build; $(FILE_BIN)
sim:
	gtkwave $(FILE_VCD)
clean:
	rm -rf build
