`ifndef TB_TEST_SV
`define TB_TEST_SV

// Base test class
class base_test extends uvm_test;
    
    `uvm_component_utils(base_test)
    
    tb_env env;
    
    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = tb_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        #100;  // Wait for reset
        run_test_sequence();
        #500;  // Settle time
        phase.drop_objection(this);
    endtask
    
    virtual task run_test_sequence();
        // Override in derived tests
    endtask

endclass : base_test

// =====================================================
// Test 1: Basic Read Test
// =====================================================
class basic_read_test extends base_test;
    
    `uvm_component_utils(basic_read_test)
    
    function new(string name = "basic_read_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_test_sequence();
	
        ahb_lite_read_seq seq;
        
        `uvm_info("TEST", "========================================", UVM_NONE)
        `uvm_info("TEST", "  Basic Read Test", UVM_NONE)
        `uvm_info("TEST", "========================================", UVM_NONE)
        #300; 
        seq = ahb_lite_read_seq::type_id::create("seq");
        assert(seq.randomize() with {
            start_addr == 32'h0000_1000;
            num_reads == 16;
        });
        seq.start(env.agent.sequencer);
        
        `uvm_info("TEST", "Basic Read Test Complete", UVM_NONE)
    endtask

endclass : basic_read_test

// =====================================================
// Test 2: Cache Behavior Test
// =====================================================
class cache_test extends base_test;
    
    `uvm_component_utils(cache_test)
    
    function new(string name = "cache_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_test_sequence();
        ahb_lite_cache_seq seq;
        
        `uvm_info("TEST", "========================================", UVM_NONE)
        `uvm_info("TEST", "  Cache Behavior Test", UVM_NONE)
        `uvm_info("TEST", "========================================", UVM_NONE)
        
	 @(posedge vif.HRESETn);     // â wait for reset to deassert
   	 repeat(10) @(posedge vif.HCLK); // â 10 cycle margin

        seq = ahb_lite_cache_seq::type_id::create("seq");
        assert(seq.randomize() with {
            base_addr == 32'h0000_2000;
        });
        seq.start(env.agent.sequencer);
	repeat(500) @(posedge vif.HCLK);
        
        `uvm_info("TEST", "Cache Test Complete", UVM_NONE)
    endtask

endclass : cache_test

// =====================================================
// Test 3: Write Test
// =====================================================
class write_test extends base_test;
    
    `uvm_component_utils(write_test)
    
    function new(string name = "write_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_test_sequence();
        ahb_lite_write_seq seq;
        
        `uvm_info("TEST", "========================================", UVM_NONE)
        `uvm_info("TEST", "  Write Test", UVM_NONE)
        `uvm_info("TEST", "========================================", UVM_NONE)
        #300;
        seq = ahb_lite_write_seq::type_id::create("seq");
        assert(seq.randomize() with {
            start_addr == 32'h0000_3000;
            num_writes == 10;
            data_pattern == 32'hDEADBEEF;
        });
        seq.start(env.agent.sequencer);
        
        `uvm_info("TEST", "Write Test Complete", UVM_NONE)
    endtask

endclass : write_test

// =====================================================
// Test 4: Read-Write-Read Test
// =====================================================
class rwr_test extends base_test;
    
    `uvm_component_utils(rwr_test)
    
    function new(string name = "rwr_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_test_sequence();
        ahb_lite_rwr_seq seq;
        
        `uvm_info("TEST", "========================================", UVM_NONE)
        `uvm_info("TEST", "  Read-Write-Read Test", UVM_NONE)
        `uvm_info("TEST", "========================================", UVM_NONE)
        
        repeat(5) begin
            seq = ahb_lite_rwr_seq::type_id::create("seq");
            assert(seq.randomize() with {
                test_addr inside {[32'h1000:32'h2000]};
            });
            seq.start(env.agent.sequencer);
        end
        
        `uvm_info("TEST", "RWR Test Complete", UVM_NONE)
    endtask

endclass : rwr_test

// =====================================================
// Test 5: Random Stress Test
// =====================================================
class random_test extends base_test;
    
    `uvm_component_utils(random_test)
    
    function new(string name = "random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_test_sequence();
        ahb_lite_random_seq seq;
        
        `uvm_info("TEST", "========================================", UVM_NONE)
        `uvm_info("TEST", "  Random Stress Test", UVM_NONE)
        `uvm_info("TEST", "========================================", UVM_NONE)
        
        seq = ahb_lite_random_seq::type_id::create("seq");
        assert(seq.randomize() with {
            num_transactions == 50;
            addr_min == 32'h0000_1000;
            addr_max == 32'h0000_5000;
        });
        seq.start(env.agent.sequencer);
        
        `uvm_info("TEST", "Random Test Complete", UVM_NONE)
    endtask

endclass : random_test

// =====================================================
// Test 6: Full Regression Test
// =====================================================
class regression_test extends base_test;
    
    `uvm_component_utils(regression_test)
    
    function new(string name = "regression_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_test_sequence();
        ahb_lite_read_seq    read_seq;
        ahb_lite_write_seq   write_seq;
        ahb_lite_cache_seq   cache_seq;
        ahb_lite_rwr_seq     rwr_seq;
        ahb_lite_random_seq  rand_seq;
        
        `uvm_info("TEST", "========================================", UVM_NONE)
        `uvm_info("TEST", "  Full Regression Test Suite", UVM_NONE)
        `uvm_info("TEST", "========================================", UVM_NONE)
        
        // Test 1: Sequential reads
        `uvm_info("TEST", "Running read test...", UVM_LOW)
        read_seq = ahb_lite_read_seq::type_id::create("read_seq");
        read_seq.randomize();
        read_seq.start(env.agent.sequencer);
        
        // Test 2: Cache behavior
        `uvm_info("TEST", "Running cache test...", UVM_LOW)
        cache_seq = ahb_lite_cache_seq::type_id::create("cache_seq");
        cache_seq.randomize();
        cache_seq.start(env.agent.sequencer);
        
        // Test 3: Writes
        `uvm_info("TEST", "Running write test...", UVM_LOW)
        write_seq = ahb_lite_write_seq::type_id::create("write_seq");
        write_seq.randomize();
        write_seq.start(env.agent.sequencer);
        
        // Test 4: RWR
        `uvm_info("TEST", "Running RWR test...", UVM_LOW)
        repeat(3) begin
            rwr_seq = ahb_lite_rwr_seq::type_id::create("rwr_seq");
            rwr_seq.randomize();
            rwr_seq.start(env.agent.sequencer);
        end
        
        // Test 5: Random
        `uvm_info("TEST", "Running random test...", UVM_LOW)
        rand_seq = ahb_lite_random_seq::type_id::create("rand_seq");
        rand_seq.randomize();
        rand_seq.start(env.agent.sequencer);
        
        `uvm_info("TEST", "========================================", UVM_NONE)
        `uvm_info("TEST", "  Regression Complete - Check Results!", UVM_NONE)
        `uvm_info("TEST", "========================================", UVM_NONE)
    endtask

endclass : regression_test

`endif
