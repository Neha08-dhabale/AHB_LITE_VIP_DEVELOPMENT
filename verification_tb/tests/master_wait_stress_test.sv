`ifndef MASTER_WAIT_STRESS_TEST_SV
`define MASTER_WAIT_STRESS_TEST_SV

class master_wait_stress_test extends base_master_test;
    
    `uvm_component_utils(master_wait_stress_test)
    
    function new(string name = "master_wait_stress_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        ahb_slave_config slave_cfg;
        
        // Create and configure BEFORE building env
        slave_cfg = ahb_slave_config::type_id::create("slave_cfg");
        slave_cfg.is_active = UVM_ACTIVE;
        slave_cfg.wait_mode = ahb_slave_config::WAIT_RANDOM;
        slave_cfg.min_wait = 10;
        slave_cfg.max_wait = 50;
        
        // Put in config_db
        uvm_config_db#(ahb_slave_config)::set(this, "env.slave_agent*", "cfg", slave_cfg);
        
        // NOW build the env
        super.build_phase(phase);
    endfunction
    
    task run_test_sequence();
        ahb_lite_read_seq master_seq;
        
        `uvm_info("TEST", "================================================", UVM_NONE)
        `uvm_info("TEST", "  MASTER VIP WAIT STATE STRESS TEST", UVM_NONE)
        `uvm_info("TEST", "  Slave will inject 10-50 wait states", UVM_NONE)
        `uvm_info("TEST", "================================================", UVM_NONE)
        
        master_seq = ahb_lite_read_seq::type_id::create("master_seq");
        assert(master_seq.randomize() with {
            start_addr == 32'h0000_1000;
            num_reads == 10;
        });
        
        `uvm_info("TEST", "Starting reads with heavy wait states...", UVM_LOW)
        master_seq.start(env.master_agent.sequencer);
        
        `uvm_info("TEST", "Wait stress test complete", UVM_NONE)
    endtask
    
endclass

`endif
