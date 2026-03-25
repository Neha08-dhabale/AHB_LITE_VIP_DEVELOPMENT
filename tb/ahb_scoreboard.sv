`ifndef AHB_SCOREBOARD_SV
`define AHB_SCOREBOARD_SV

class ahb_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(ahb_scoreboard)
    
    // Analysis import
    uvm_analysis_imp #(ahb_lite_seq_item, ahb_scoreboard) ap_imp;
    
    // Statistics
    int num_reads;
    int num_writes;
    int num_errors;
    int num_unchecked;
    int total_wait_cycles;
    int min_wait_cycles;
    int max_wait_cycles;
    
    // Cache statistics
    int cache_hits;
    int cache_misses;
    
    // Expected memory pre-loaded from flash model layout
    // Key = AHB word address, Value = expected 32-bit HRDATA (little-endian assembled)
    bit [31:0] memory [bit [31:0]];
    
    // Address tracking
    bit [31:0] last_addr;
    int sequential_accesses;
    
    function new(string name = "ahb_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        ap_imp          = new("ap_imp", this);
        min_wait_cycles = 999999;
        max_wait_cycles = 0;
    endfunction

    
    // build_phase: pre-load expected values from flash model
    // Must mirror flash_model initial block, assembled as
    // little-endian 32-bit words:
    //   HRDATA[7:0]   = memory[addr+0]
    //   HRDATA[15:8]  = memory[addr+1]
    //   HRDATA[23:16] = memory[addr+2]
    //   HRDATA[31:24] = memory[addr+3]
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        load_expected_memory();
    endfunction

    function void load_expected_memory();

        // Cache line 1: 0x1000 to 0x101F (8 words)
        memory[32'h0000_1000] = 32'h44332211;  // flash: 11 22 33 44
        memory[32'h0000_1004] = 32'hDDCCBBAA;  // flash: AA BB CC DD
        memory[32'h0000_1008] = 32'hEFBEADDE;  // flash: DE AD BE EF
        memory[32'h0000_100C] = 32'hBEBAFECA;  // flash: CA FE BA BE
        memory[32'h0000_1010] = 32'hAAAAAAAA;  // default fill
        memory[32'h0000_1014] = 32'hAAAAAAAA;
        memory[32'h0000_1018] = 32'hAAAAAAAA;
        memory[32'h0000_101C] = 32'hAAAAAAAA;

        // Cache line 2: 0x1020 to 0x103F (8 words)
        memory[32'h0000_1020] = 32'h88776655;  // flash: 55 66 77 88
        memory[32'h0000_1024] = 32'hBBBBBBBB;  // fill pattern
        memory[32'h0000_1028] = 32'hBBBBBBBB;
        memory[32'h0000_102C] = 32'hBBBBBBBB;
        memory[32'h0000_1030] = 32'hBBBBBBBB;
        memory[32'h0000_1034] = 32'hBBBBBBBB;
        memory[32'h0000_1038] = 32'hBBBBBBBB;
        memory[32'h0000_103C] = 32'hBBBBBBBB;
	
	// Write-test address: flash bytes DE AD BE EF â LE word = 0xEFBEADDE
   	memory[32'h0000_3000] = 32'hEFBEADDE;

	// Cache test region: base_addr=0x2000, all default 0xAA fill
    	memory[32'h0000_2000] = 32'hAAAAAAAA;
    	memory[32'h0000_2004] = 32'hAAAAAAAA;
    	memory[32'h0000_2008] = 32'hAAAAAAAA;
    	memory[32'h0000_200C] = 32'hAAAAAAAA;
    	// second cache line (0x2010)
    	memory[32'h0000_2010] = 32'hAAAAAAAA;
   	memory[32'h0000_2014] = 32'hAAAAAAAA;
    	memory[32'h0000_2018] = 32'hAAAAAAAA;
    	memory[32'h0000_201C] = 32'hAAAAAAAA;
	memory[32'h0000_2020] = 32'hAAAAAAAA;   // default fill
    	memory[32'h0000_2024] = 32'hAAAAAAAA;
    	memory[32'h0000_2028] = 32'hAAAAAAAA;
    	memory[32'h0000_202C] = 32'hAAAAAAAA;
    	memory[32'h0000_2030] = 32'hAAAAAAAA;
    	memory[32'h0000_2034] = 32'hAAAAAAAA;
    	memory[32'h0000_2038] = 32'hAAAAAAAA;
    	memory[32'h0000_203C] = 32'hAAAAAAAA;

    	// 0x3000 region: flash bytes DE AD BE EF â little-endian = 0xEFBEADDE
    memory[32'h0000_3000] = 32'hEFBEADDE;
    memory[32'h0000_3004] = 32'hAAAAAAAA;   // rest of line is default
   
        `uvm_info("SB", "Expected memory pre-loaded from flash model layout", UVM_LOW)
    endfunction

    
    // write: called by monitor via analysis port
    
    function void write(ahb_lite_seq_item txn);

        // Update wait cycle statistics
        total_wait_cycles += txn.wait_cycles;
        if (txn.wait_cycles < min_wait_cycles)
            min_wait_cycles = txn.wait_cycles;
        if (txn.wait_cycles > max_wait_cycles)
            max_wait_cycles = txn.wait_cycles;

        // Classify cache hit/miss
        // In write() function:
	if (txn.wait_cycles < 10)
    		cache_hits++;
	else if (txn.wait_cycles > 50)  // 193 >> 50, so this works â
    		cache_misses++;
	// Add explicit log for misses:
	if (txn.wait_cycles > 50)
    	`uvm_info("SB", $sformatf(
        "CACHE MISS detected: [0x%08h] waits=%0d cycles",
        txn.addr, txn.wait_cycles), UVM_LOW)
        // Track sequential accesses
        if (txn.addr == last_addr + 4)
            sequential_accesses++;
        last_addr = txn.addr;

        // Route to write or read checker
        if (txn.write)
            check_write(txn);
        else
            check_read(txn);

        if (txn.resp == ERROR)
            num_errors++;

    endfunction

    
    // check_write: DUT is read-only XIP so writes have no effect
    
    function void check_write(ahb_lite_seq_item txn);
        num_writes++;
        `uvm_warning("SB", $sformatf(
            "WRITE IGNORED: [0x%08h] = 0x%08h | DUT is READ-ONLY XIP, write has no effect",
            txn.addr, txn.data))
    endfunction

    
    // check_read: compare HRDATA against pre-loaded expected
    
    function void check_read(ahb_lite_seq_item txn);
        bit [31:0] expected;
        num_reads++;

        if (memory.exists(txn.addr)) begin
            expected = memory[txn.addr];
            if (txn.data !== expected) begin
                `uvm_error("SB", $sformatf(
                    "READ MISMATCH: [0x%08h] Expected=0x%08h Got=0x%08h (waits=%0d)",
                    txn.addr, expected, txn.data, txn.wait_cycles))
            end else begin
                `uvm_info("SB", $sformatf(
                    "READ MATCH: [0x%08h] = 0x%08h (waits=%0d)",
                    txn.addr, txn.data, txn.wait_cycles), UVM_MEDIUM)
            end
        end else begin
            // Address outside pre-loaded table not checked, flag it
            num_unchecked++;
            `uvm_warning("SB", $sformatf(
                "READ UNCHECKED: [0x%08h] = 0x%08h (waits=%0d) add to load_expected_memory()",
                txn.addr, txn.data, txn.wait_cycles))
        end

    endfunction

    
    // report_phase
        function void report_phase(uvm_phase phase);
        real avg_wait;
        real hit_rate;
        int  total_accesses;

        super.report_phase(phase);

        total_accesses = num_reads + num_writes;

        `uvm_info("SB_REPORT", "========================================================", UVM_NONE)
        `uvm_info("SB_REPORT", "              SCOREBOARD STATISTICS                     ", UVM_NONE)
        `uvm_info("SB_REPORT", "========================================================", UVM_NONE)
        `uvm_info("SB_REPORT", $sformatf("Total Transactions:   %0d", total_accesses),    UVM_NONE)
        `uvm_info("SB_REPORT", $sformatf("  Reads:              %0d", num_reads),          UVM_NONE)
        `uvm_info("SB_REPORT", $sformatf("  Writes:             %0d", num_writes),         UVM_NONE)
        `uvm_info("SB_REPORT", $sformatf("  Errors:             %0d", num_errors),         UVM_NONE)
        `uvm_info("SB_REPORT", $sformatf("  Unchecked Reads:    %0d", num_unchecked),      UVM_NONE)
        `uvm_info("SB_REPORT", "--------------------------------------------------------", UVM_NONE)

        if (total_accesses > 0) begin
            avg_wait = real'(total_wait_cycles) / real'(total_accesses);
            `uvm_info("SB_REPORT", "Wait Cycle Statistics:",                                     UVM_NONE)
            `uvm_info("SB_REPORT", $sformatf("  Average:            %.2f cycles", avg_wait),     UVM_NONE)
            `uvm_info("SB_REPORT", $sformatf("  Minimum:            %0d cycles", min_wait_cycles), UVM_NONE)
            `uvm_info("SB_REPORT", $sformatf("  Maximum:            %0d cycles", max_wait_cycles), UVM_NONE)
        end

        `uvm_info("SB_REPORT", "--------------------------------------------------------", UVM_NONE)
        `uvm_info("SB_REPORT", "Cache Behavior:",                                          UVM_NONE)
        `uvm_info("SB_REPORT", $sformatf("  Hits (< 10 cycles): %0d", cache_hits),        UVM_NONE)
        `uvm_info("SB_REPORT", $sformatf("  Misses (> 50 cyc):  %0d", cache_misses),      UVM_NONE)

        if (total_accesses > 0) begin
            hit_rate = (real'(cache_hits) / real'(total_accesses)) * 100.0;
            `uvm_info("SB_REPORT", $sformatf("  Hit Rate:           %.1f%%", hit_rate),    UVM_NONE)
        end

        `uvm_info("SB_REPORT", "--------------------------------------------------------", UVM_NONE)
        `uvm_info("SB_REPORT", "Access Patterns:",                                         UVM_NONE)
        `uvm_info("SB_REPORT", $sformatf("  Sequential:         %0d", sequential_accesses), UVM_NONE)
        `uvm_info("SB_REPORT", "========================================================", UVM_NONE)

        // Final verdict
        if (num_errors == 0 && num_unchecked == 0)
            `uvm_info("SB_REPORT", "RESULT: ALL READS MATCHED EXPECTED VALUES *** PASS ***", UVM_NONE)
        else if (num_errors > 0)
            `uvm_error("SB_REPORT", $sformatf(
                "RESULT: %0d MISMATCHES FOUND *** FAIL ***", num_errors))
        else
            `uvm_warning("SB_REPORT", $sformatf(
                "RESULT: %0d unchecked reads add addresses to load_expected_memory()", num_unchecked))

    endfunction

endclass : ahb_scoreboard

`endif

