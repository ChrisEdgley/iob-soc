#FIRMWARE
FIRM_ADDR_W:=13

#SRAM
SRAM_ADDR_W=13

#DDR
ifeq ($(USE_DDR),)
	USE_DDR:=0
endif
ifeq ($(RUN_DDR),)
	RUN_DDR:=0
endif

DDR_ADDR_W:=30
CACHE_ADDR_W:=24

#ROM
BOOTROM_ADDR_W:=12

#Init memory (only works in simulation or in FPGA)
ifeq ($(INIT_MEM),)
	INIT_MEM:=0
endif

#Peripheral list (must match respective submodule or folder name in the submodules directory)
PERIPHERALS:=UART

#SIMULATION TEST
SIM_LIST="SIMULATOR=icarus" "SIMULATOR=ncsim"
#SIM_LIST="SIMULATOR=icarus"

ifeq ($(SIMULATOR),ncsim)
	SIM_USER=user19
	SIM_SERVER=$(SIM_USER)@micro7.lx.it.pt
else
#default
	SIMULATOR:=icarus
endif

#BOARD TEST
BOARD_LIST="BOARD=CYCLONEV-GT-DK" "BOARD=AES-KU040-DB-G"
#BOARD_LIST="BOARD=CYCLONEV-GT-DK"

ifeq ($(BOARD),AES-KU040-DB-G)
	COMPILE_USER=$(USER)
	COMPILE_SERVER=$(COMPILE_USER)@pudim-flan.iobundle.com
	COMPILE_OBJ=synth_system.bit
	BOARD_USER=$(USER)
	BOARD_SERVER=$(BOARD_USER)@baba-de-camelo.iobundle.com
else
#default
	BOARD=CYCLONEV-GT-DK
	COMPILE_USER=$(USER)
	COMPILE_SERVER=$(COMPILE_USER)@pudim-flan.iobundle.com
	COMPILE_OBJ=output_files/top_system.sof
	BOARD_USER=$(USER)
	BOARD_SERVER=$(BOARD_USER)@pudim-flan.iobundle.com
endif

#ROOT DIR ON REMOTE MACHINES
REMOTE_ROOT_DIR=./sandbox/iob-soc

#ASIC
ASIC_NODE:=umc130

#DOC_TYPE
DOC_TYPE:=presentation


#
#DO NOT EDIT BEYOND THIS POINT
#

#object directories
HW_DIR:=$(ROOT_DIR)/hardware
SIM_DIR=$(HW_DIR)/simulation/$(SIMULATOR)
FPGA_DIR=$(HW_DIR)/fpga/$(BOARD)
ASIC_DIR=$(HW_DIR)/asic/$(ASIC_NODE)


SW_DIR:=$(ROOT_DIR)/software
FIRM_DIR:=$(SW_DIR)/firmware
BOOT_DIR:=$(SW_DIR)/bootloader
CONSOLE_DIR:=$(SW_DIR)/console
PYTHON_DIR:=$(SW_DIR)/python

DOC_DIR:=$(ROOT_DIR)/document/$(DOC_TYPE)

#submodule paths
SUBMODULES_DIR=$(ROOT_DIR)/submodules
CPU_DIR:=$(SUBMODULES_DIR)/iob-picorv32
CACHE_DIR:=$(SUBMODULES_DIR)/iob-cache
INTERCON_DIR:=$(CACHE_DIR)/submodules/iob-interconnect
MEM_DIR:=$(CACHE_DIR)/submodules/iob-mem
AXI_MEM_DIR:=$(CACHE_DIR)/submodules/axi-mem

#defmacros
DEFINE+=$(defmacro)BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=$(defmacro)SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=$(defmacro)FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=$(defmacro)CACHE_ADDR_W=$(CACHE_ADDR_W)

ifeq ($(USE_DDR),1)
DEFINE+=$(defmacro)USE_DDR
DEFINE+=$(defmacro)DDR_ADDR_W=$(DDR_ADDR_W)
ifeq ($(RUN_DDR),1)
DEFINE+=$(defmacro)RUN_DDR
endif
endif
ifeq ($(INIT_MEM),1)
DEFINE+=$(defmacro)INIT_MEM 
endif
DEFINE+=$(defmacro)N_SLAVES=$(N_SLAVES) 
#address select bits: Extra memory (E), Peripherals (P), Boot controller (B)
DEFINE+=$(defmacro)E=31
DEFINE+=$(defmacro)P=30
DEFINE+=$(defmacro)B=29
ifeq ($(MAKECMDGOALS),)
BAUD:=30000000
else ifeq ($(word 1, $(MAKECMDGOALS)),sim)
BAUD:=30000000
else
BAUD:=115200
endif
DEFINE+=$(defmacro)BAUD=$(BAUD)
DEFINE+=$(defmacro)FREQ=100000000
dummy:= $(shell echo $(BAUD))

#run target by default
TARGET:=run

all: usage $(TARGET)


usage:
	@echo "Usage: make target [parameters]"

#create periph indices and directories
N_SLAVES:=0
dummy:=$(foreach p, $(PERIPHERALS), $(eval $p_DIR:=$(SUBMODULES_DIR)/$p))
dummy:=$(foreach p, $(PERIPHERALS), $(eval $p=$(N_SLAVES)) $(eval N_SLAVES:=$(shell expr $(N_SLAVES) \+ 1)))
dummy:=$(foreach p, $(PERIPHERALS), $(eval DEFINE+=$(defmacro)$p=$($p)))

#test log
ifneq ($(TEST_LOG),)
LOG=>test.log
endif

.PHONY: all
