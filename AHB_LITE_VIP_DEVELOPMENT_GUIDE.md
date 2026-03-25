# AHB-Lite Master VIP Development Guide
## Complete Journey from Scratch to Working Verification Environment

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Session 1: Project Setup & Slave VIP](#session-1-project-setup--slave-vip)
3. [Session 2: Master VIP Development](#session-2-master-vip-development)
4. [Session 3: Debugging & Bug Fixes](#session-3-debugging--bug-fixes)
5. [Session 4: Final Integration & Testing](#session-4-final-integration--testing)
6. [All File Locations](#all-file-locations)
7. [Complete Code Listings](#complete-code-listings)
8. [Verification Results](#verification-results)

---

## Project Overview

**Goal:** Create a complete AHB-Lite Master VIP verification environment with:
- Master VIP (Device Under Test)
- Slave VIP (Verification responder)
- Protocol compliance checking
- Functional checking
- Multiple test scenarios

**Directory Structure:**

ahb_lite_vip_project/vip/src/                    # Master VIP
slave_vip/src/            			  # Slave VIP
 verification_tb/          			  # Testbench
	 tests/
	scoreboards/ Makefile
 Makefile


---

## Session 1: Project Setup & Slave VIP

### Query 1: Initial Project Structure
**Problem:** Need to set up the entire project from scratch

**Solution:** Created directory structure and Makefile
```bash
mkdir -p ~/ahb_lite_vip_project/{vip/src/sequences,slave_vip/src,verification_tb/{tests,scoreboards}}
cd ~/ahb_lite_vip_project
```

### Query 2: Slave VIP Not Available
**Problem:** Master VIP needs a responding slave for verification

**Solution:** Built complete Slave VIP with:
- `ahb_slave_seq_item.sv` - Transaction type
- `ahb_slave_driver.sv` - Drives responses
- `ahb_slave_monitor.sv` - Observes transactions
- `ahb_slave_agent.sv` - Contains driver/monitor
- `ahb_slave_memory.sv` - Memory model
- `ahb_slave_config.sv` - Configuration object

---

## Session 2: Master VIP Development

### Query 3: Master VIP Components
**Problem:** Need all master VIP components

**Files Created:**
- `ahb_lite_if.sv` - Interface with clocking blocks
- `ahb_lite_seq_item.sv` - Transaction
- `ahb_lite_driver.sv` - Master driver
- `ahb_lite_monitor.sv` - Master monitor
- `ahb_lite_sequencer.sv` - Sequencer
- `ahb_lite_agent.sv` - Agent
- `ahb_lite_config.sv` - Configuration

### Query 4: Sequences Development
**Problem:** Need reusable sequences for testing

**Files Created:**
- `ahb_lite_base_seq.sv` - Base with helper tasks
- `ahb_lite_write_seq.sv` - Write sequence
- `ahb_lite_read_seq.sv` - Read sequence
- `ahb_lite_rwr_seq.sv` - Read-Write-Read test

---


### Bug 6: ERROR Response Implementation
**Problem:** ERROR must be asserted for 2 cycles per AHB spec

**Fix:** Two-cycle error sequence
```systemverilog
if (return_error) begin
    // Cycle 1: HRESP=1, HREADYOUT=0
    HRESP <= 1; HREADYOUT <= 0;
    @(vif.slave_cb);
    
    // Cycle 2: HRESP=1, HREADYOUT=1
    HRESP <= 1; HREADYOUT <= 1;
end
```

### Bug 7: ERROR Data Handling
**Problem:** Driver should ignore HRDATA during ERROR

**Fix:** Check response before sampling
```systemverilog
txn.resp = ahb_hresp_e'(vif.master_cb.HRESP);

if (!txn.write) begin
    if (txn.resp == OKAY)
        txn.data = vif.master_cb.HRDATA;
    else
        txn.data = 32'hXXXXXXXX;  // Invalid
end
```

## Session 4: Final Integration & Testing

### Tests Developed

1. **master_write_test.sv** - Basic write verification
2. **master_read_test.sv** - Basic read verification
3. **master_mixed_test.sv** - Reads + Writes + RWR patterns
4. **master_error_test.sv** - ERROR response handling
5. **master_wait_stress_test.sv** - High wait state stress

### Scoreboards

1. **master_protocol_checker.sv** - Protocol compliance
   - Checks for protocol violations
   - Reports violations

2. **master_functional_checker.sv** - Data correctness
   - Compares master vs slave transactions
   - Handles ERROR transactions (skips data check)
   - Reports matches/mismatches

---

## All File Locations

### Master VIP (`vip/src/`)
- ahb_lite_if.sv
- ahb_lite_types_pkg.sv
- ahb_lite_seq_item.sv
- ahb_lite_driver.sv
- ahb_lite_monitor.sv
- ahb_lite_sequencer.sv
- ahb_lite_agent.sv
- ahb_lite_config.sv
- ahb_lite_pkg.sv

### Sequences (`vip/src/sequences/`)
- ahb_lite_base_seq.sv
- ahb_lite_write_seq.sv
- ahb_lite_read_seq.sv
- ahb_lite_rwr_seq.sv

### Slave VIP (`slave_vip/src/`)
- ahb_slave_seq_item.sv
- ahb_slave_driver.sv
- ahb_slave_monitor.sv
- ahb_slave_sequencer.sv
- ahb_slave_agent.sv
- ahb_slave_memory.sv
- ahb_slave_config.sv
- ahb_slave_pkg.sv

### Verification TB (`verification_tb/`)
- master_verification_tb_top.sv
- master_verification_env.sv

### Tests (`verification_tb/tests/`)
- base_master_test.sv
- master_write_test.sv
- master_read_test.sv
- master_mixed_test.sv
- master_error_test.sv
- master_wait_stress_test.sv

### Scoreboards (`verification_tb/scoreboards/`)
- master_protocol_checker.sv
- master_functional_checker.sv

---


---

## Verification Results

### Final Test Results (All Passing)
```
make verify_master_vip

TEST 1: master_write_test
Writes: 5, Matches: 5, Mismatches: 0
â PASS

TEST 2: master_read_test  
Reads: 8, Matches: 8, Mismatches: 0
â PASS

TEST 3: master_mixed_test
Reads: 22, Writes: 15, Matches: 37, Mismatches: 0
â PASS

TEST 4: master_error_test
Errors: 1, Matches: 10, Mismatches: 0
â PASS

TEST 5: master_wait_stress_test
Reads: 10, Matches: 10, Mismatches: 0
â PASS

OVERALL: 5/5 TESTS PASSED
```

## How to Rebuild From This Document

1. Create directory structure
2. Copy all code files in order
3. Run: `make clean && make compile_master_verif`
4. Run: `make verify_master_vip`
5. Expect: 5/5 tests passing, 0 errors

---





# AHB-Lite VIP Implementation Queries

## Query List for Rebuilding VIP-VIP Integration from Scratch

---

## Setup Queries

### Query 1: Project Structure Setup
"I need to set up an AHB-Lite Master VIP verification project from scratch. Create the directory structure and Makefile for a complete verification environment with Master VIP, Slave VIP, testbench, tests, and scoreboards."

---

## Slave VIP Implementation

### Query 2: Slave VIP Need
"The Master VIP needs a responding slave for verification. Build a complete Slave VIP with driver, monitor, agent, memory model, and configuration that can:
- Respond to read/write transactions
- Insert configurable wait states
- Return ERROR responses at specific addresses
- Store and retrieve data from memory"

---

## Master VIP Implementation

### Query 3: Master VIP Interface
"Create the AHB-Lite interface (ahb_lite_if.sv) with proper clocking blocks for master, slave, and monitor. Include all AHB-Lite signals: HADDR, HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HSEL, HRDATA, HREADY, HREADYOUT, HRESP."

### Query 4: Master VIP Types Package
"Create ahb_lite_types_pkg.sv with all AHB-Lite enumerated types: HTRANS (IDLE, BUSY, NONSEQ, SEQ), HSIZE (BYTE to 32WORD), HBURST (SINGLE, INCR, WRAP4, etc.), HRESP (OKAY, ERROR)."

### Query 5: Master VIP Transaction
"Create ahb_lite_seq_item.sv - the transaction class with address, write direction, data, transfer type, size, burst, protection, response, and wait cycles. Include constraints for word-aligned addresses."

### Query 6: Master VIP Configuration
"Create ahb_lite_config.sv with configuration for active/passive mode, master/slave mode selection, and maximum wait cycles."

### Query 7: Master VIP Driver
"Create ahb_lite_driver.sv that:
- Drives address phase (HADDR, HTRANS, HWRITE, HSIZE, etc.)
- Drives data phase (HWDATA for writes)
- Waits for HREADYOUT
- Samples HRDATA for reads (only on OKAY response)
- Captures response (HRESP) and wait cycles
- Handles timeout scenarios"

### Query 8: Master VIP Monitor
"Create ahb_lite_monitor.sv that:
- Observes transactions on the bus
- Uses state machine to track address phase data phase transition
- Captures HWDATA at data phase start for writes
- Samples HRDATA at completion for reads
- Counts wait states
- Sends transactions to analysis port"

### Query 9: Master VIP Agent & Package
"Create ahb_lite_agent.sv (contains driver, monitor, sequencer) and ahb_lite_pkg.sv (packages all master VIP components)."

---

## Sequences Implementation

### Query 10: Base Sequence
"Create ahb_lite_base_seq.sv with helper tasks send_read() and send_write() that handle parameter passing to randomize constraints correctly."

### Query 11: Write Sequence
"Create ahb_lite_write_seq.sv that performs configurable number of sequential write transactions with incrementing data pattern."

### Query 12: Read Sequence
"Create ahb_lite_read_seq.sv that performs configurable number of sequential read transactions."

### Query 13: Read-Write-Read Sequence
"Create ahb_lite_rwr_seq.sv that tests read-modify-write pattern: read initial value, write new value, read back and verify."

---

## Verification Environment

### Query 14: Testbench Top
"Create master_verification_tb_top.sv with:
- Clock and reset generation
- Interface instantiation
- VIF configuration in config_db
- UVM test execution"

### Query 15: Verification Environment
"Create master_verification_env.sv that:
- Contains master agent (DUT)
- Contains slave agent (responder)
- Contains protocol scoreboard
- Contains functional scoreboard
- Configures both agents
- Connects analysis ports to scoreboards"

---

## Tests Implementation

### Query 16: Base Test
"Create base_master_test.sv that builds the environment and provides virtual task run_test_sequence() for derived tests."

### Query 17: Write Test
"Create master_write_test.sv that runs write sequence and verifies all writes complete successfully."

### Query 18: Read Test
"Create master_read_test.sv that:
- Pre-loads memory with test pattern
- Runs read sequence
- Verifies data matches"

### Query 19: Mixed Test
"Create master_mixed_test.sv that runs:
- Write sequence
- Read sequence
- Multiple read-write-read patterns"

### Query 20: Error Test
"Create master_error_test.sv that:
- Configures slave to return ERROR at specific addresses
- Runs read sequence
- Verifies master receives ERROR response
- Verifies data is marked invalid (0xXXXXXXXX) for ERROR transactions"

### Query 21: Wait Stress Test
"Create master_wait_stress_test.sv that:
- Configures slave for high wait states (10-50 cycles)
- Runs transactions
- Verifies correct operation under stress"

---

## Scoreboards Implementation

### Query 22: Protocol Checker
"Create master_protocol_checker.sv that monitors for AHB protocol violations and reports statistics."

### Query 23: Functional Checker
"Create master_functional_checker.sv that:
- Compares master transactions vs slave transactions
- Checks address, direction, and data match
- For ERROR responses: verifies error flags match but SKIPS data comparison
- For OKAY responses: verifies data matches exactly
- Reports reads, writes, errors, matches, and mismatches"

---

## Build & Verification

### Query 24: Compile and Run
"Provide commands to:
1. Clean and compile all components
2. Run each individual test
3. Run complete test suite (verify_master_vip)
4. Expected results for all passing tests"

---

## Usage Instructions

**To rebuild the entire VIP from scratch:**

1. Start a new chat session with Claude
2. Paste Query 1
3. Wait for complete code response
4. Paste Query 2
5. Continue through Query 24
6. Execute build commands

**Expected Final Result:**
```
make verify_master_vip

â master_write_test PASS (5 writes, 0 errors)
â master_read_test PASS (8 reads, 0 errors)
â master_mixed_test PASS (37 transactions, 0 errors)
â master_error_test PASS (1 error handled correctly)
â master_wait_stress_test PASS (10 reads with heavy waits)

5/5 TESTS PASSED
```

---

## Notes

- These queries represent ONLY the initial implementation requests
- Bug fixes and debugging sessions are NOT included
- Each query builds upon previous ones
- Follow queries in sequential order
- All code will be production-ready with proper:
  - Clocking block usage (#1step delays)
  - State machine for transaction tracking
  - Pipeline handling
  - Error response protocol (2-cycle assertion)
  - Data capture timing

