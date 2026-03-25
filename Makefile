
# ============================================================================
# Makefile for AHB-Lite VIP with QSPI XIP Controller
# Simple: Direct GUI shortcuts for each test
# ============================================================================

# Simulator
SIM = questa

# Directories
VIP_SRC = vip/src
VIP_SEQ = vip/src/sequences
DUT_SRC = dut
TB_SRC = tb
SIM_DIR = sim
WORK = work

# Source files
VIP_FILES = $(VIP_SRC)/ahb_lite_if.sv \
            $(VIP_SRC)/ahb_lite_pkg.sv  

MASTER_IF = $(VIP_SRC)/master_ahb_if.sv
SLAVE_IF = $(SLAVE_VIP_SRC)/slave_ahb_if.sv


DUT_FILES = $(DUT_SRC)/EF_QSPI_XIP_CTRL_AHBL.v \
            $(DUT_SRC)/EF_QSPI_XIP_CTRL.v \
            $(DUT_SRC)/DMC.v \
            $(DUT_SRC)/flash_model.sv

TB_FILES = $(TB_SRC)/tb_top.sv

# Compilation flags
VLOG_FLAGS = +incdir+$(VIP_SRC) +incdir+$(VIP_SEQ) +incdir+$(TB_SRC) \
             +incdir+../EF_IP_UTIL/hdl/rtl

VSIM_FLAGS = -voptargs=+acc -suppress 3009 -suppress 8887

# Default test
TEST = basic_read_test

# ============================================================================
# PHONY TARGETS
# ============================================================================
.PHONY: all compile sim clean help \
        cache cache_gui \
        basic_read basic_read_gui \
        write write_gui \
        rwr rwr_gui \
        random random_gui \
        regression regression_gui \
        run_all

# ============================================================================
# DEFAULT
# ============================================================================
all: compile sim

# ============================================================================
# COMPILATION
# ============================================================================
compile:
	@echo "==================================="
	@echo "  Compiling AHB-Lite VIP Project"
	@echo "==================================="
	@mkdir -p $(SIM_DIR)
	@mkdir -p $(WORK)
	vlib $(WORK)
	vmap work $(CURDIR)/$(WORK)
	@echo ""
	@echo "Compiling VIP..."
	vlog -work $(WORK) $(VLOG_FLAGS) $(VIP_FILES)
	@echo ""
	@echo "Compiling DUT..."
	vlog -work $(WORK) $(VLOG_FLAGS) $(DUT_FILES)
	@echo ""
	@echo "Compiling Testbench..."
	vlog -work $(WORK) $(VLOG_FLAGS) $(TB_FILES)
	@echo ""
	@echo "â Compilation successful!"

# ============================================================================
# SIMULATION (Console Mode)
# ============================================================================
sim:
	@echo ""
	@echo "==================================="
	@echo "  Running Simulation (Console)"
	@echo "  Test: $(TEST)"
	@echo "==================================="
	cd $(SIM_DIR) && vsim -c -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.tb_top \
		+UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-do "run -all; quit -f"
	@echo ""
	@echo "â Simulation complete!"
	@echo "  Log: sim/transcript"

# ============================================================================
# CACHE TEST
# ============================================================================
cache: compile
	@echo "Running cache test (console)..."
	@$(MAKE) -s sim TEST=cache_test

cache_gui: compile
	@echo ""
	@echo "==================================="
	@echo "  Opening GUI: Cache Test"
	@echo "==================================="
	@echo "Add signals manually in GUI, then run simulation"
	@echo ""
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.tb_top \
		+UVM_TESTNAME=cache_test \
		+UVM_VERBOSITY=UVM_MEDIUM

# ============================================================================
# BASIC READ TEST
# ============================================================================
basic_read: compile
	@echo "Running basic read test (console)..."
	@$(MAKE) -s sim TEST=basic_read_test

basic_read_gui: compile
	@echo ""
	@echo "==================================="
	@echo "  Opening GUI: Basic Read Test"
	@echo "==================================="
	@echo "Add signals manually in GUI, then run simulation"
	@echo ""
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.tb_top \
		+UVM_TESTNAME=basic_read_test \
		+UVM_VERBOSITY=UVM_MEDIUM

# ============================================================================
# WRITE TEST
# ============================================================================
write: compile
	@echo "Running write test (console)..."
	@$(MAKE) -s sim TEST=write_test

write_gui: compile
	@echo ""
	@echo "==================================="
	@echo "  Opening GUI: Write Test"
	@echo "==================================="
	@echo "Add signals manually in GUI, then run simulation"
	@echo ""
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.tb_top \
		+UVM_TESTNAME=write_test \
		+UVM_VERBOSITY=UVM_MEDIUM

# ============================================================================
# READ-WRITE-READ TEST
# ============================================================================
rwr: compile
	@echo "Running RWR test (console)..."
	@$(MAKE) -s sim TEST=rwr_test

rwr_gui: compile
	@echo ""
	@echo "==================================="
	@echo "  Opening GUI: Read-Write-Read Test"
	@echo "==================================="
	@echo "Add signals manually in GUI, then run simulation"
	@echo ""
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.tb_top \
		+UVM_TESTNAME=rwr_test \
		+UVM_VERBOSITY=UVM_MEDIUM

# ============================================================================
# RANDOM TEST
# ============================================================================
random: compile
	@echo "Running random test (console)..."
	@$(MAKE) -s sim TEST=random_test

random_gui: compile
	@echo ""
	@echo "==================================="
	@echo "  Opening GUI: Random Test"
	@echo "==================================="
	@echo "Add signals manually in GUI, then run simulation"
	@echo ""
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.tb_top \
		+UVM_TESTNAME=random_test \
		+UVM_VERBOSITY=UVM_MEDIUM

# ============================================================================
# REGRESSION TEST
# ============================================================================
regression: compile
	@echo "Running regression test (console)..."
	@$(MAKE) -s sim TEST=regression_test

regression_gui: compile
	@echo ""
	@echo "==================================="
	@echo "  Opening GUI: Regression Test"
	@echo "==================================="
	@echo "Add signals manually in GUI, then run simulation"
	@echo ""
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.tb_top \
		+UVM_TESTNAME=regression_test \
		+UVM_VERBOSITY=UVM_MEDIUM

# ============================================================================
# RUN ALL TESTS
# ============================================================================
run_all: compile
	@echo ""
	@echo "========================================="
	@echo "  Running Complete Test Suite"
	@echo "========================================="
	@echo ""
	@PASS=0; FAIL=0; \
	for test in basic_read_test cache_test write_test rwr_test random_test regression_test; do \
		echo "Running: $$test"; \
		$(MAKE) -s sim TEST=$$test > $(SIM_DIR)/$$test.log 2>&1; \
		if grep -q "UVM_ERROR\|UVM_FATAL" $(SIM_DIR)/$$test.log; then \
			echo "  Result: FAILED â"; \
			FAIL=$$((FAIL+1)); \
		else \
			echo "  Result: PASSED â"; \
			PASS=$$((PASS+1)); \
		fi; \
		echo ""; \
	done; \
	echo "========================================="; \
	echo "  Test Summary"; \
	echo "========================================="; \
	echo "  Passed: $$PASS"; \
	echo "  Failed: $$FAIL"; \
	echo "  Total:  $$((PASS+FAIL))"; \
	echo "========================================="; \
	if [ $$FAIL -eq 0 ]; then \
		echo "â All tests PASSED!"; \
	else \
		echo "â Some tests FAILED - check logs in sim/"; \
	fi

# ============================================================================
# CLEAN
# ============================================================================
clean:
	@echo "Cleaning build files..."
	rm -rf $(WORK)
	rm -rf $(SIM_DIR)/*.vcd
	rm -rf $(SIM_DIR)/*.log
	rm -rf $(SIM_DIR)/transcript
	rm -rf $(SIM_DIR)/vsim.wlf
	rm -rf $(SIM_DIR)/.vstf
	@echo "â Clean complete"

# ============================================================================
# HELP
# ============================================================================
help:
	@echo ""
	@echo "============================================"
	@echo "  AHB-Lite VIP Makefile"
	@echo "============================================"
	@echo ""
	@echo "Console Mode (Fast - No GUI):"
	@echo "  make cache           - Cache test"
	@echo "  make basic_read      - Basic read test"
	@echo "  make write           - Write test"
	@echo "  make rwr             - Read-Write-Read test"
	@echo "  make random          - Random test"
	@echo "  make regression      - Regression test"
	@echo "  make run_all         - Run all tests"
	@echo ""
	@echo "GUI Mode (Add Waves Manually):"
	@echo "  make cache_gui       - Cache test in GUI"
	@echo "  make basic_read_gui  - Basic read in GUI"
	@echo "  make write_gui       - Write test in GUI"
	@echo "  make rwr_gui         - RWR test in GUI"
	@echo "  make random_gui      - Random test in GUI"
	@echo "  make regression_gui  - Regression in GUI"
	@echo ""
	@echo "Master VIP Verification:"
	@echo "  make verify_master_vip      - Run all master VIP tests"
	@echo "  make master_write_verif     - Master write test"
	@echo "  make master_read_verif      - Master read test"
	@echo "  make master_mixed_verif     - Master mixed test"
	@echo "  make master_error_verif     - Master error test"
	@echo "  make master_wait_verif      - Master wait stress test"
	@echo ""
	@echo "Other:"
	@echo "  make compile         - Compile only"
	@echo "  make clean           - Clean build"
	@echo "  make help            - Show this help"
	@echo ""
	@echo "============================================"
	@echo "Examples:"
	@echo "============================================"
	@echo ""
	@echo "  # Run cache test in console"
	@echo "  make cache"
	@echo ""
	@echo "  # Open GUI for cache test"
	@echo "  make cache_gui"
	@echo ""
	@echo "  # Then in GUI:"
	@echo "  #   1. Add signals you need"
	@echo "  #   2. Run â Run -All"
	@echo "  #   3. View waveforms"
	@echo ""
	@echo "  # Run all tests"
	@echo "  make run_all"
	@echo ""
	@echo "  # Verify Master VIP"
	@echo "  make verify_master_vip"
	@echo ""
	@echo "============================================"

.DEFAULT_GOAL := help
# ============================================================================
# MASTER VIP VERIFICATION (with Slave VIP)
# ============================================================================

# Additional source files
SLAVE_VIP_PKG = $(SLAVE_VIP_SRC)/ahb_slave_pkg.sv
VERIF_TB = $(VERIF_TB_SRC)/master_verification_tb_top.sv

# Compile for master verification
compile_master_verif:
	@echo "==================================="
	@echo "  Compiling Master VIP Verification"
	@echo "==================================="
	@mkdir -p $(SIM_DIR)
	@mkdir -p $(WORK)
	vlib $(WORK)
	vmap work $(CURDIR)/$(WORK)
	@echo ""
	@echo "Step 1: Compiling Master Interface..."
	vlog -work $(WORK) $(VLOG_FLAGS) vip/src/master_ahb_if.sv
	@echo ""
	@echo "Step 2: Compiling Slave Interface..."
	vlog -work $(WORK) $(VLOG_FLAGS) slave_vip/src/slave_ahb_if.sv
	@echo ""
	@echo "Step 3: Compiling Master VIP Package..."
	vlog -work $(WORK) $(VLOG_FLAGS) vip/src/ahb_lite_pkg.sv
	@echo ""
	@echo "Step 4: Compiling Slave VIP Package..."
	vlog -work $(WORK) $(VLOG_FLAGS) slave_vip/src/ahb_slave_pkg.sv
	@echo ""
	@echo "Step 5: Compiling Verification TB..."
	vlog -work $(WORK) $(VLOG_FLAGS) +incdir+verification_tb +incdir+verification_tb/tests +incdir+verification_tb/scoreboards verification_tb/master_verification_tb_top.sv
	@echo ""
	@echo "â Master verification compilation successful!"

# Run master verification tests
master_write_verif: compile_master_verif
	@echo ""
	@echo "Running Master Write Verification..."
	cd $(SIM_DIR) && vsim -c -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_write_test \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-do "run -all; quit -f"

master_read_verif: compile_master_verif
	@echo ""
	@echo "Running Master Read Verification..."
	cd $(SIM_DIR) && vsim -c -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_read_test \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-do "run -all; quit -f"

master_wait_verif: compile_master_verif
	@echo ""
	@echo "Running Master Wait State Verification..."
	cd $(SIM_DIR) && vsim -c -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_wait_stress_test \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-do "run -all; quit -f"

master_error_verif: compile_master_verif
	@echo ""
	@echo "Running Master Error Handling Verification..."
	cd $(SIM_DIR) && vsim -c -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_error_test \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-do "run -all; quit -f"

master_mixed_verif: compile_master_verif
	@echo ""
	@echo "Running Master Mixed R/W Verification..."
	cd $(SIM_DIR) && vsim -c -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_mixed_test \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-do "run -all; quit -f"

# Run all master verification tests
verify_master_vip: compile_master_verif
	@echo ""
	@echo "========================================="
	@echo "  Running Complete Master VIP Verification Suite"
	@echo "========================================="
	@echo ""
	@$(MAKE) -s master_write_verif
	@$(MAKE) -s master_read_verif
	@$(MAKE) -s master_wait_verif
	@$(MAKE) -s master_error_verif
	@$(MAKE) -s master_mixed_verif
	@echo ""
	@echo "========================================="
	@echo "  Master VIP Verification Complete!"
	@echo "========================================="

# GUI for master verification
master_verif_write_gui: compile_master_verif
	@echo ""
	@echo "Opening Master VIP Verification in GUI..."
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_write_test \
		+UVM_VERBOSITY=UVM_MEDIUM

master_verif_read_gui: compile_master_verif
	@echo ""
	@echo "Opening Master VIP Verification in GUI..."
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_read_test \
		+UVM_VERBOSITY=UVM_MEDIUM

master_verif_mixed_gui: compile_master_verif
	@echo ""
	@echo "Opening Master VIP Verification in GUI..."
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_mixed_test \
		+UVM_VERBOSITY=UVM_MEDIUM

master_verif_error_gui: compile_master_verif
	@echo ""
	@echo "Opening Master VIP Verification in GUI..."
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_error_test \
		+UVM_VERBOSITY=UVM_MEDIUM

master_verif_stress_gui: compile_master_verif
	@echo ""
	@echo "Opening Master VIP Verification in GUI..."
	cd $(SIM_DIR) && vsim -modelsimini ../modelsim.ini $(VSIM_FLAGS) work.master_verification_tb_top \
		+UVM_TESTNAME=master_wait_stress_test \
		+UVM_VERBOSITY=UVM_MEDIUM

.PHONY: compile_master_verif master_write_verif master_read_verif master_wait_verif master_error_verif master_mixed_verif verify_master_vip \
        master_verif_write_gui master_verif_read_gui master_verif_mixed_gui master_verif_error_gui master_verif_stress_gui
