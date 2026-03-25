`ifndef MASTER_MIXED_TEST_SV
`define MASTER_MIXED_TEST_SV

class master_mixed_test extends base_master_test;
    
    `uvm_component_utils(master_mixed_test)
    
    function new(string name = "master_mixed_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_test_sequence();
        ahb_lite_write_seq write_seq;
        ahb_lite_read_seq  read_seq;
        ahb_lite_rwr_seq   rwr_seq;
        
        `uvm_info("TEST", "================================================", UVM_NONE)
        `uvm_info("TEST", "  MASTER VIP MIXED READ/WRITE TEST", UVM_NONE)
        `uvm_info("TEST", "================================================", UVM_NONE)
        
        // Write some data
        write_seq = ahb_lite_write_seq::type_id::create("write_seq");
        assert(write_seq.randomize() with {
            start_addr == 32'h0000_3000;
            num_writes == 10;
            data_pattern == 32'hDEAD0000;
        });
        write_seq.start(env.master_agent.sequencer);
        
        // Read it back
        read_seq = ahb_lite_read_seq::type_id::create("read_seq");
        assert(read_seq.randomize() with {
            start_addr == 32'h0000_3000;
            num_reads == 10;
        });
        read_seq.start(env.master_agent.sequencer);
        
        // Read-write-read patterns
        repeat(5) begin
            rwr_seq = ahb_lite_rwr_seq::type_id::create("rwr_seq");
            assert(rwr_seq.randomize() with {
                test_addr inside {[32'h3000:32'h3100]};
            });
            rwr_seq.start(env.master_agent.sequencer);
        end
        
        `uvm_info("TEST", "Mixed test complete", UVM_NONE)
    endtask

endclass

`endif
