CPU     ?= ml1
CPU_LIST = test ml1 ml2 ml3
MEM     ?= direct
MEM_LIST = direct axi4-lite axi4

ifeq ($(filter $(CPU_LIST), $(CPU)),)
    ifeq ($(findstring $(MAKECMDGOALS), config|clean),)
        $(error $$CPU is incorrect, optional values in [$(CPU_LIST)])
    endif
endif
ifeq ($(filter $(MEM_LIST), $(MEM)),)
    ifeq ($(findstring $(MAKECMDGOALS), config|clean),)
        $(error $$MEM is incorrect, optional values in [$(MEM_LIST)])
    endif
endif

CPU_PREFIX = $(CPU)
CPU_UPPER  = $(shell echo $(CPU) | tr a-z A-Z)

CPU_BLACKLIST = $(filter-out $(CPU), $(CPU_LIST))
CPU_BLACKLIT_PREFIX =
$(foreach str, $(CPU_BLACKLIST), \
    $(eval CPU_BLACKLIT_PREFIX += $(str)))

ifeq ($(wildcard $(METEOR_ENV_HOME)/core/src/main.c),)
    $(error METEOR_HOME=$(METEOR_HOME) is not a METEOR repo)
endif

-include $(METEOR_ENV_HOME)/core/include/config/auto.conf
-include $(METEOR_ENV_HOME)/core/include/config/auto.conf.cmd

FUNC_REMOVE_QUOTE = $(patsubst "%",%,$(1))

CFG_CFLAGS_TOP_NAME    = Top
CFG_GUEST_ISA         ?= $(call FUNC_REMOVE_QUOTE, $(CONFIG_ISA))
CFG_ENGINE            ?= $(call FUNC_REMOVE_QUOTE, $(CONFIG_ENGINE))
CFG_DIFFTEST_REF_PATH ?= $(call FUNC_REMOVE_QUOTE, $(CONFIG_DIFFTEST_REF_PATH))
CFG_DIFFTEST_REF_NAME ?= $(call FUNC_REMOVE_QUOTE, $(CONFIG_DIFFTEST_REF_NAME))

BUILD_DIR = $(METEOR_CPU_HOME)/rtl/build
OBJ_DIR   = $(BUILD_DIR)/obj_dir

METEOR_BIN_NAME = $(CFG_GUEST_ISA)-meteor-$(CFG_ENGINE)
METEOR_BIN      = $(BUILD_DIR)/$(METEOR_BIN_NAME)

VERILATOR         = verilator
VERILATOR_CFLAGS += -MMD --build -cc                                \
                    -O3 --x-assign fast --x-initial fast --noassert \
                    --trace                                         \
                    +incdir+$(METEOR_CPU_HOME)/rtl/srcv/mem         \

INCS_DIR = $(METEOR_ENV_HOME)/core/include           \
           $(METEOR_ENV_HOME)/core/include/generated
INCS     = $(shell find $(INCS_DIR) -name "*.h")
INCFLAGS = $(addprefix -I, $(INCS_DIR))

CFLAGS_BUILD += $(call FUNC_REMOVE_QUOTE, $(CONFIG_CC_OPT))     \
                $(if $(CONFIG_CC_LTO), -flto,)                  \
                $(if $(CONFIG_CC_DEBUG), -Og -ggdb3,)           \
                $(if $(CONFIG_CC_ASAN), -fsanitize=address,)    \
                -DCFLAGS_CPU_TYPE=$(CPU_UPPER)                  \
                -DCFLAGS_CPU_TYPE_$(CPU_UPPER)                  \
                -DCFLAGS_GUEST_ISA=$(CFG_GUEST_ISA)             \
                -DCFLAGS_TOP_NAME="\"V$(CFG_CFLAGS_TOP_NAME)\""

CFLAGS += $(CFLAGS_BUILD)                          \
          -Wno-unused-result                       \
          $(INCFLAGS)                              \
          $(shell llvm-config-11 --cxxflags) -fPIE

LDFLAGS += $(CFLAGS_BUILD)                \
           -lreadline -ldl -pie           \
           $(shell llvm-config-11 --libs) \
           -lSDL2

SRCSS_DIR           = $(abspath $(METEOR_CPU_HOME)/rtl/src)
SRCSS_SRC_BLACKLIST =
SRCSS_DIR_BLACKLIST = $(addprefix $(SRCSS_DIR)/core/, $(CPU_BLACKLIT_PREFIX))
SRCSS_BLACKLIST     = $(SRCSS_SRC_BLACKLIST)                                  \
                      $(shell find $(SRCSS_DIR_BLACKLIST) -name "*.scala")
SRCSS_WHITELIST     = $(shell find $(SRCSS_DIR) -name "*.scala")
SRCSS               = $(filter-out $(SRCSS_BLACKLIST), $(SRCSS_WHITELIST))

SRCVS_DIR = $(METEOR_CPU_HOME)/rtl/srcv
SRCVS_GEN = $(BUILD_DIR)/$(CFG_CFLAGS_TOP_NAME).v
SRCVS     = $(shell find $(SRCVS_DIR) -name "*.v")

SRCCS_DIR = $(METEOR_ENV_HOME)/core/src
SRCCS_SRC_BLACKLIST =
SRCCS_DIR_BLACKLIST = $(shell [ "$(CONFIG_DEVICE)" = "y" ] && echo ||      \
                      echo $(METEOR_ENV_HOME)/core/src/device)
SRCCS_BLACKLIST     = $(SRCCS_SRC_BLACKLIST)                               \
                      $(shell find $(SRCCS_DIR_BLACKLIST) -name "*.c")
SRCCS_WHITELIST     = $(shell find $(SRCCS_DIR) -name "*.c")
SRCCS               = $(filter-out $(SRCCS_BLACKLIST), $(SRCCS_WHITELIST)) \
                      $(METEOR_ENV_HOME)/core/src/util/disasm.cc

SRCS = $(SRCVS_GEN) $(SRCVS) $(SRCCS)

CONFIG = $(METEOR_ENV_HOME)/core/.config

TEMP_SRCSS_BUILD_PATH = $(SRCSS_DIR)/temp/Build.scala
TEMP_SRCSS_BUILD_INFO = "package cpu.temp\n\ntrait Build {\n    val CPU_TYPE = \"$(CPU)\"\n    val MEM_TYPE = \"$(MEM)\"\n}"

TEMP_SRCSS_TOPMAIN_PATH    = $(SRCSS_DIR)/temp/TopMain.scala
TEMP_SRCSS_TOPMAIN_INFO_L1 = "import circt.stage._\n"
TEMP_SRCSS_TOPMAIN_INFO_L2 = "object TopMain extends App {"
TEMP_SRCSS_TOPMAIN_INFO_L3 = "    def top = new cpu.core.${CPU_PREFIX}.Top();"
TEMP_SRCSS_TOPMAIN_INFO_L4 = "    val firtoolOptions = Array(\"--lowering-options=\" + List("
TEMP_SRCSS_TOPMAIN_INFO_L5 = "        \"disallowLocalVariables\","
TEMP_SRCSS_TOPMAIN_INFO_L6 = "        \"disallowPackedArrays\","
TEMP_SRCSS_TOPMAIN_INFO_L7 = "        \"locationInfoStyle=wrapInAtSquareBracket\""
TEMP_SRCSS_TOPMAIN_INFO_L8 = "    ).reduce(_ + \",\" + _))"
TEMP_SRCSS_TOPMAIN_INFO_L9 = "    ChiselStage.emitSystemVerilogFile(top, args, firtoolOptions)"
TEMP_SRCSS_TOPMAIN_INFO_LA = "}"

MEM_TIME_TYPE ?= ASYNC
ifeq ($(CPU), ml2)
    ifeq ($(MEM), axi4-lite)
        MEM_TIME_TYPE = SYNC
    endif
endif
TEMP_SRCVS_BUILD_PATH = $(SRCVS_DIR)/temp/Build.v
TEMP_SRCVS_BUILD_INFO = "// \`define MEM_DBUG_INST\n// \`define MEM_DBUG_DATA\n\`define MEM_TIME_$(MEM_TIME_TYPE)"

ifeq ($(findstring $(MAKECMDGOALS), config|clean),)
    ifeq ($(shell cat $(TEMP_SRCSS_BUILD_PATH) | grep $(CPU)),)
        $(shell rm -rf out)
        $(shell rm -rf test_run_dir)
        $(shell rm -rf rtl/build)
    endif
    ifeq ($(shell cat $(TEMP_SRCSS_TOPMAIN_PATH) | grep $(MEM_TIME_TYPE)),)
        $(shell rm -rf rtl/build)
    endif
endif

$(SRCVS_GEN): $(SRCSS)
	mkdir -p $(SRCSS_DIR)/temp
	echo $(TEMP_SRCSS_BUILD_INFO)       > $(TEMP_SRCSS_BUILD_PATH)   && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L1)  > $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L2) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L3) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L4) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L5) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L6) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L7) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L8) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_L9) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	echo $(TEMP_SRCSS_TOPMAIN_INFO_LA) >> $(TEMP_SRCSS_TOPMAIN_PATH) && \
	mkdir -p $(BUILD_DIR) &&                                            \
	mill -i cpu.runMain TopMain -td $(BUILD_DIR)
$(METEOR_BIN): $(INCS) $(SRCS) $(CONFIG)
	mkdir -p $(SRCVS_DIR)/temp
	echo $(TEMP_SRCVS_BUILD_INFO) > $(TEMP_SRCVS_BUILD_PATH)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS)            \
	--top-module $(CFG_CFLAGS_TOP_NAME) $(SRCS) \
	$(addprefix -CFLAGS ,  $(CFLAGS))           \
	$(addprefix -LDFLAGS , $(LDFLAGS))          \
	--Mdir $(OBJ_DIR) --exe -o                  \
	$(abspath $(METEOR_BIN))

include $(METEOR_ENV_HOME)/core/tool/difftest.mk

override ARGS ?= -l $(BUILD_DIR)/log.txt
override ARGS += $(ARGS_DIFF)

IMG ?=
METEOR_EXEC := $(METEOR_BIN) $(ARGS) $(IMG)

.PHONY: config test gen run gdb sim fmt cfmt clean bsp

config:
	cd ../env/core && make menuconfig

test:
	mill -i cpu.test

gen: $(SRCVS_GEN)

run: $(METEOR_BIN) $(DIFFTEST_REF_SO)
	rm -rf $(BUILD_DIR)/wave.vcd
	@echo $(CPUS)
	@echo $(ARGS)
	@echo $(IMG)
	$(METEOR_EXEC)

gdb: $(METEOR_BIN)
	rm -rf $(BUILD_DIR)/wave.vcd
	gdb -s $(METEOR_BIN) --ARGS_EMBED $(METEOR_EXEC)

sim: $(METEOR_BIN)
	gtkwave $(BUILD_DIR)/wave.vcd

fmt:
	mill -i cpu.reformat

cfmt:
	mill -i cpu.checkFormat

clean:
	rm -rf out
	rm -rf test_run_dir
	rm -rf rtl/build

bsp:
	mill -i mill.bsp.BSP/install
