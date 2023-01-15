PROJ = icesugar-z80

PACKAGE = sg48
DEVICE = up5k
SERIES = synth_ice40
YOSYS_ARG = -dsp
#ROUTE_ARG = --seed 10 --freq 12
PROGRAMMER = icesprog

# ----------------------------------------------------------------------------------

FPGA_SRC = ./src
PIN_DEF = ./icesugar.pcf
TOP_FILE = $(shell echo $(FPGA_SRC)/top.v)
TB_FILE :=  $(shell echo $(FPGA_SRC)/*_tb.v)

# ----------------------------------------------------------------------------------

FW_DIR = firmware
FW_INCLUDE = $(FW_DIR)/include
FW_SRC = $(FW_DIR)/src
FW_SRC_FILE = $(shell cd $(FW_SRC) && echo *.c)
FW_ASM_FILE = $(shell cd $(FW_DIR) && echo *.s)
CODE_LOCATION = 0x0200
DATA_LOCATION = 0x8000
ARCH = mz80

# ----------------------------------------------------------------------------------

FORMAT = "verilog-format"
TOOLCHAIN_PATH = /opt/fpga
BUILD_DIR = build
#Creates a temporary PATH.
TOOLCHAIN_PATH := $(shell echo $$(readlink -f $(TOOLCHAIN_PATH)))
PATH := $(shell echo $(TOOLCHAIN_PATH)/*/bin | sed 's/ /:/g'):$(PATH)

all: build_fw  synthesis

synthesis: $(BUILD_DIR) $(BUILD_DIR)/$(PROJ).bin
# rules for building the blif file
$(BUILD_DIR)/%.json: $(TOP_FILE) $(FPGA_SRC)/*.v $(FPGA_SRC)/tv80/*.v
	yosys -q  -f "verilog -D__def_fw_img=\"$(BUILD_DIR)/$(PROJ)_fw.vhex\"" -l $(BUILD_DIR)/build.log -p '$(SERIES) $(YOSYS_ARG) -top top -json $@; show -format dot -prefix $(BUILD_DIR)/$(PROJ)' $< 
# asc
$(BUILD_DIR)/%.asc: $(BUILD_DIR)/%.json $(PIN_DEF)
	nextpnr-ice40 -l $(BUILD_DIR)/nextpnr.log $(ROUTE_ARG) --package $(PACKAGE) --$(DEVICE) --asc $@ --pcf $(PIN_DEF) --json $<
# bin, for programming
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.asc
	icepack $< $@
# timing
$(BUILD_DIR)/%.rpt: $(BUILD_DIR)/%.asc
	icetime -d $(DEVICE) -mtr $@ $<

sim: $(BUILD_DIR) build_fw $(BUILD_DIR)/%.vcd  
$(BUILD_DIR)/%.vcd: $(BUILD_DIR)/$(PROJ).out 
	vvp -v -M $(TOOLCHAIN_PATH)/toolchain-iverilog/lib/ivl $< 
	mv ./*.vcd $(BUILD_DIR)

$(BUILD_DIR)/%.out: $(FPGA_SRC)/*.v $(FPGA_SRC)/tv80/*.v
	iverilog -o $@ -D__def_fw_img=\"$(BUILD_DIR)/$(PROJ)_fb.vhex\" -B $(TOOLCHAIN_PATH)/toolchain-iverilog/lib/ivl $(TOOLCHAIN_PATH)/toolchain-yosys/share/yosys/ice40/cells_sim.v $(TOP_FILE) $(TB_FILE)

# Flash memory firmware
flash: $(BUILD_DIR)/$(PROJ).bin
	$(PROGRAMMER) $<

# Flash in SRAM
prog: $(BUILD_DIR)/$(PROJ).bin
	$(PROGRAMMER) -S $<

formatter:
	if [ $(FORMAT) == "istyle" ]; then istyle  -t4 -b -o --pad=block $(FPGA_SRC)/*.v; fi
	if [ $(FORMAT) == "verilog-format" ]; then find ./src/*.v | xargs -t -L1 java -jar ${TOOLCHAIN_PATH}/verilog-format/bin/verilog-format.jar -s .verilog-format -f ; fi
	
#FIXME:
build_fw: $(BUILD_DIR) $(BUILD_DIR)/$(PROJ)_fw.bin $(BUILD_DIR)/$(PROJ)_fw.hex $(BUILD_DIR)/$(PROJ)_fw.vhex
#build_fw: $(ASM_OBJ) $(CC_OBJ)
# Compile Files
CC = sdcc -$(ARCH) --std-sdcc99 --max-allocs-per-node 10000 --opt-code-size --code-loc $(CODE_LOCATION) --data-loc $(DATA_LOCATION)
ASM_OBJ = $(patsubst %.s,$(BUILD_DIR)/%.rel,$(FW_ASM_FILE))
CC_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.rel,$(FW_SRC_FILE))
$(ASM_OBJ): 
	sdasz80 -go $@ $(subst .rel,.s, $(subst $(BUILD_DIR),$(FW_DIR),$@))
$(CC_OBJ):
	$(CC) -I $(FW_INCLUDE) -c $(subst .rel,.c, $(subst $(BUILD_DIR),$(FW_SRC),$@) ) -o $@
# Linker
$(BUILD_DIR)/$(PROJ)_fw.hex: $(ASM_OBJ) $(CC_OBJ)
	$(CC) --no-std-crt0 $^ -o $@_tmp
	packihx < $@_tmp > $@
# Output
$(BUILD_DIR)/$(PROJ)_fw.bin: $(BUILD_DIR)/$(PROJ)_fw.hex
	srec_cat -multiple $< -intel -o $@ -binary

$(BUILD_DIR)/$(PROJ)_fw.vhex: $(BUILD_DIR)/$(PROJ)_fw.hex
	srec_cat -multiple $< -intel -o $@ -VMem 8
# Disassembler 
$(BUILD_DIR)/$(PROJ)_fw.dasm: $(BUILD_DIR)/$(PROJ)_fw.bin
	z80dasm -t -g 0x0 -l $< -o $@

clean:
	rm -f $(BUILD_DIR)/*

toolchain:
	chmod +x ./toolchain/*.sh
	sudo ./toolchain/install.sh $(TOOLCHAIN_PATH)
	if [ -d ".vscode" ]; then sed -i 's@\(\"verilog.linting.path\":\)[^,]*@\1 "${TOOLCHAIN_PATH}/toolchain-iverilog/bin/"@' .vscode/settings.json; fi
	if [ -d ".vscode" ]; then sed -i 's@\(\"verilog.linting.iverilog.arguments\":\)[^,]*@\1 "-B ${TOOLCHAIN_PATH}/toolchain-iverilog/lib/ivl"@' .vscode/settings.json; fi

#secondary needed or make will remove useful intermediate files
.SECONDARY:
.PHONY: all synthesis sim flash prog formatter build_fw clean toolchain

# $@ The file name of the target of the rule.rule
# $< first pre requisite
# $^ names of all preerquisites
