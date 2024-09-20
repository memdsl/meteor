.PHONY: run sim clean

CFG_TOP = ifu_tb
CFG_CXX = g++

CXX_VER = $(shell g++ -dumpversion | cut -d. -f1)
ifeq ($(shell [ $(CXX_VER) -le 9 ] && echo yes || echo no), yes)
    ifeq ($(shell command -v g++-10 >/dev/null 2>&1 && echo yes || echo no), yes)
        CFG_CXX = g++-10
    else
        $(error "Please install >=10 version, such as g++-10")
    endif
endif

VERILATOR      = verilator
VERILATOR_ARGS = --cc                    \
                 --exe                   \
                 --Mdir build            \
                 --MMD                   \
                 --o $(FILE_BIN)          \
                 --timing                \
                 --top-module $(CFG_TOP) \
                 --trace

CFLAGS  = -std=c++20  \
          -fcoroutines
LDFLAGS =

INCS_SV  = -I$(METEOR_HOME)/rtl/base
INCS     =   $(INCS_SV)

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
