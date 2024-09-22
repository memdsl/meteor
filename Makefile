CPU     ?= l1
CPU_LIST = $(basename $(shell ls $(METEOR_HOME)/rtl/core))
ifeq ($(filter $(CPU_LIST), $(CPU)),)
    ifeq ($(findstring $(MAKECMDGOALS), config|clean),)
        $(error [error]: $$CPU is incorrect, optional values in [$(CPU_LIST)])
    endif
endif
CPU_BLACKLIST = $(filter-out $(CPU), $(CPU_LIST))

TEST     ?=
TEST_LIST = $(subst _tb,,$(basename $(shell ls $(METEOR_HOME)/tb/$(CPU))))
ifeq ($(filter $(TEST_LIST), $(TEST)),)
    ifeq ($(findstring $(MAKECMDGOALS), config|clean),)
        $(error [error]: $$TEST is incorrect, optional values in [$(TEST_LIST)])
    endif
endif

 TOP = $(TEST)_tb
VTOP = V$(TOP)

VERILATOR      = verilator
VERILATOR_ARGS = --cc                \
                 --exe               \
                 --Mdir build        \
                 --MMD               \
                 --o $(FILE_BIN)     \
                 --timing            \
                 --top-module $(TOP) \
                 --trace

CXX = g++
CXX_VERSION = $(shell g++ -dumpversion | cut -d. -f1)
ifeq ($(shell [ $(CXX_VERSION) -le 9 ] && echo yes || echo no), yes)
    ifeq ($(shell command -v g++-10 >/dev/null 2>&1 && echo yes || echo no), yes)
        CXX = g++-10
    else
        $(error [error] g++ version must >=10, such as g++-10)
    endif
endif

INFO = "\#define VTOP_H \"$(VTOP).h\"\n\#define  TOP_W \"$(TOP).vcd\""

CXX_CFLAGS  =  -std=c++20               \
               -fcoroutines             \
               -DTOP=$(TOP)             \
              '-DTOP_W=\"$(TOP).vcd\"'  \
               -DVTOP=$(VTOP)           \
              '-DVTOP_H=\"$(VTOP).h\"'
CXX_LDFLAGS =

INCS_SV_DIR  = $(METEOR_HOME)/rtl/base     \
               $(METEOR_HOME)/rtl/base/reg \
               $(METEOR_HOME)/rtl/base/mux
INCS_SV      = $(addprefix -I, $(INCS_SV_DIR))
INCS_CXX_DIR = $(METEOR_HOME)/sim
INCS_CXX     = $(addprefix -I, $(shell find $(INCS_CXX_DIR) -name "*.h"))
INCS         = $(INCS_SV)

SRCS_SV_DIR           = $(METEOR_HOME)/rtl \
                        $(METEOR_HOME)/tb
SRCS_SV_SRC_BLACKLIST =
SRCS_SV_DIR_BLACKLIST = $(addprefix $(METEOR_HOME)/rtl/core/, $(CPU_BLACKLIST)) \
                        $(addprefix $(METEOR_HOME)/tb/,       $(CPU_BLACKLIST))
SRCS_SV_BLACKLIST     = $(SRCS_SV_SRC_BLACKLIST)                            \
                        $(shell find $(SRCS_SV_DIR_BLACKLIST) -name "*.sv")
SRCS_SV_WHITELIST     = $(shell find $(SRCS_SV_DIR) -name "*.sv")
SRCS_SV               = $(filter-out $(SRCS_SV_BLACKLIST), $(SRCS_SV_WHITELIST))

SRCS_CXX = sim/sim.cpp
SRCS     = $(SRCS_SV) $(SRCS_CXX)

FILE_MK  = $(VTOP).mk
FILE_BIN = $(METEOR_HOME)/build/meteor
FILE_VCD = $(METEOR_HOME)/build/$(TOP).vcd

$(FILE_MK):
	$(VERILATOR) $(VERILATOR_ARGS)         \
	$(INCS) $(SRCS)                        \
	$(addprefix -CFLAGS ,  $(CXX_CFLAGS))  \
	$(addprefix -LDFLAGS , $(CXX_LDFLAGS))
$(FILE_BIN): $(FILE_MK)
	cat sim/sim.h
	grep -q $(TEST) sim/sim.h || echo $(INFO) > sim/sim.h
	make -C build -f $(FILE_MK) CXX=$(CXX)

.PHONY: run sim clean

run: $(FILE_BIN)
	cd build && $(FILE_BIN)
sim:
	gtkwave $(FILE_VCD)
clean:
	rm -rf build
