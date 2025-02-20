TOOL_EMPTY :=
TOOL_SPACE := $(TOOL_EMPTY) $(TOOL_EMPTY)
TOOL_COMMA := ,$(TOOL_SPACE)

CPU     ?= l1
CPU_LIST = $(basename $(shell ls rtl/core))
ifeq ($(filter $(CPU_LIST), $(CPU)),)
    ifeq ($(findstring $(MAKECMDGOALS), config|clean),)
        $(error [error]: $$CPU is incorrect, optional values in \
       [$(subst $(TOOL_SPACE),$(TOOL_COMMA),$(CPU_LIST))])
    endif
endif
CPU_BLACKLIST = $(filter-out $(CPU), $(CPU_LIST))

TEST     ?=
TEST_LIST = $(shell find tb/$(CPU) -type f | sed "s|.*/||; s|_tb\.sv$$||")
ifeq ($(filter $(TEST_LIST), $(TEST)),)
    ifeq ($(findstring $(MAKECMDGOALS), config|clean),)
        $(error [error]: $$TEST is incorrect, optional values in \
       [$(subst $(TOOL_SPACE),$(TOOL_COMMA),$(TEST_LIST))])
    endif
endif

 TOP = $(TEST)_tb
VTOP = V$(TOP)

GTKW = $(shell pwd)/wave/$(CPU)/$(TOP).gtkw
ifeq ($(shell find $(GTKW) -type f > /dev/null 2>&1 && echo yes || echo no), no)
    GTKW =
endif

BUILD_DIR = $(METEOR_HOME)/build
BUILD_MK  = $(VTOP).mk
BUILD_BIN = $(BUILD_DIR)/meteor
BUILD_VCD = $(BUILD_DIR)/$(TOP).vcd

VERILATOR      = verilator
VERILATOR_ARGS = --cc                \
                 --exe               \
                 --Mdir build        \
                 --MMD               \
                 --o $(BUILD_BIN)    \
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

CXX_SIM_H = "\#define VTOP_H \"$(VTOP).h\""

CXX_CFLAGS  =  -std=c++20                    \
               -fcoroutines                  \
              '-DTOP_W=\"build/$(TOP).vcd\"' \
               -DVTOP=$(VTOP)
CXX_LDFLAGS =

INCS_SV_DIR  = rtl/base
INCS_SV      = $(addprefix -I, $(INCS_SV_DIR))
INCS_CXX_DIR = sim
INCS_CXX     = $(addprefix -I, $(shell find $(INCS_CXX_DIR) -name "*.h"))
INCS         = $(INCS_SV)

SRCS_SV_DIR           = rtl \
                        tb
SRCS_SV_SRC_BLACKLIST =
SRCS_SV_DIR_BLACKLIST = $(addprefix rtl/core/, $(CPU_BLACKLIST)) \
                        $(addprefix tb/,       $(CPU_BLACKLIST))
SRCS_SV_BLACKLIST     = $(SRCS_SV_SRC_BLACKLIST)                            \
                        $(shell find $(SRCS_SV_DIR_BLACKLIST) -name "*.sv")
SRCS_SV_WHITELIST     = $(shell find $(SRCS_SV_DIR) -name "*.sv")
SRCS_SV               = $(filter-out $(SRCS_SV_BLACKLIST), $(SRCS_SV_WHITELIST))

SRCS_CXX = sim/sim.cpp
SRCS     = $(SRCS_SV) $(SRCS_CXX)

$(BUILD_MK):
	$(VERILATOR) $(VERILATOR_ARGS)         \
	$(INCS) $(SRCS)                        \
	$(addprefix -CFLAGS ,  $(CXX_CFLAGS))  \
	$(addprefix -LDFLAGS , $(CXX_LDFLAGS))
$(BUILD_BIN): $(BUILD_MK)
	touch sim/sim.h
	grep -q $(TEST) sim/sim.h || echo $(CXX_SIM_H) > sim/sim.h
	make -C build -f $(BUILD_MK) CXX=$(CXX)

.PHONY: clean run sim

run: $(BUILD_BIN)
	$(BUILD_BIN)
sim:
	gtkwave $(BUILD_VCD) $(GTKW)
clean:
	rm -rf build
