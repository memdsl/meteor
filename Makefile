CPU     ?= l1
CPU_LIST = $(basename $(shell ls $(METEOR_HOME)/rtl/core))
ifeq ($(filter $(CPU_LIST), $(CPU)),)
    ifeq ($(findstring $(MAKECMDGOALS), config|clean),)
        $(error [error]: $$CPU is incorrect, optional values in [$(CPU_LIST)])
    endif
endif
CPU_BLACKLIST = $(filter-out $(CPU), $(CPU_LIST))




TEST ?= ifu







CFG_TOP = ifu_tb



VERILATOR      = verilator
VERILATOR_ARGS = --cc                    \
                 --exe                   \
                 --Mdir build            \
                 --MMD                   \
                 --o $(FILE_BIN)          \
                 --timing                \
                 --top-module $(CFG_TOP) \
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
CXX_CFLAGS  = -std=c++20 \
              -fcoroutines
CXX_LDFLAGS =

INCS_SV_DIR  = $(METEOR_HOME)/rtl/base     \
               $(METEOR_HOME)/rtl/base/reg \
               $(METEOR_HOME)/rtl/base/mux
INCS_SV      = $(addprefix -I, $(INCS_SV_DIR))
INCS_CXX_DIR =
INCS_CXX     = $(addprefix -I, $(shell find $(INCS_CXX_DIR) -name "*.h"))
INCS         = $(INCS_SV) $(INCS_CXX)

SRCS_SV_DIR           = $(METEOR_HOME)/rtl \
                        $(METEOR_HOME)/tb/
SRCS_SV_SRC_BLACKLIST =
SRCS_SV_DIR_BLACKLIST = $(addprefix $(METEOR_HOME)/rtl/core/, $(CPU_BLACKLIST)) \
                        $(addprefix $(METEOR_HOME)/tb/,       $(CPU_BLACKLIST))
SRCS_SV_BLACKLIST     = $(SRCS_SV_SRC_BLACKLIST)                            \
                        $(shell find $(SRCS_SV_DIR_BLACKLIST) -name "*.sv")
SRCS_SV_WHITELIST     = $(shell find $(SRCS_SV_DIR) -name "*.sv")
SRCS_SV               = $(filter-out $(SRCS_SV_BLACKLIST), $(SRCS_SV_WHITELIST))

SRCS_CXX = sim/sim.cpp
SRCS     = $(SRCS_SV) $(SRCS_CXX)

FILE_MK  = V$(CFG_TOP).mk
FILE_BIN = $(METEOR_HOME)/build/meteor
FILE_VCD = $(METEOR_HOME)/build/$(CFG_TOP).vcd

$(FILE_MK):
	$(VERILATOR) $(VERILATOR_ARGS)         \
	$(INCS) $(SRCS)                        \
	$(addprefix -CFLAGS ,  $(CXX_CFLAGS))  \
	$(addprefix -LDFLAGS , $(CXX_LDFLAGS))
$(FILE_BIN): $(FILE_MK)
	make -C build -f $(FILE_MK) CXX=$(CXX)

.PHONY: run sim clean

run: $(FILE_BIN)
	@echo $(CPU)
	cd build && $(FILE_BIN)
sim:
	gtkwave $(FILE_VCD)
clean:
	rm -rf build
