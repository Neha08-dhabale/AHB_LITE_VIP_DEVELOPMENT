`ifndef MASTER_WRITE_TEST_SV
`define MASTER_WRITE_TEST_SV

class master_write_test extends base_master_test;
    
    `uvm_component_utils(master_write_test)
    
    function new(string name = "master_write_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_test_sequence();
        ahb_lite_write_seq master_seq;
        
        `uvm_info("TEST", "================================================", UVM_NONE)
        `uvm_info("TEST", "  MASTER VIP WRITE VERIFICATION TEST", UVM_NONE)
        `uvm_info("TEST", "================================================", UVM_NONE)
        
        // Issue writes from master, slave will respond
        master_seq = ahb_lite_write_seq::type_id::create("master_seq");
        assert(master_seq.randomize() with {
            start_addr == 32'h0000_2000;
            num_writes == 5;
            data_pattern == 32'hCAFE0000;
        });
        
        `uvm_info("TEST", "Starting 20 write transactions...", UVM_LOW)
        master_seq.start(env.master_agent.sequencer);
        
        `uvm_info("TEST", "Write test complete", UVM_NONE)
    endtask

endclass

`endif
