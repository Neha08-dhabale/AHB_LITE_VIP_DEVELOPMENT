`ifndef BASE_MASTER_TEST_SV
`define BASE_MASTER_TEST_SV

class base_master_test extends uvm_test;
    
    `uvm_component_utils(base_master_test)
    
    master_verification_env env;
   // virtual master_ahb_if vif;
ahb_slave_config slave_cfg;
    
    function new(string name = "base_master_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = master_verification_env::type_id::create("env", this);
        
        // Get master interface from config_db
       // if (!uvm_config_db#(virtual master_ahb_if)::get(this, "", "vif", vif))
        //    `uvm_fatal("NOVIF", "Virtual interface not found in test")

	slave_cfg = ahb_slave_config::type_id::create("slave_cfg");
    slave_cfg.wait_mode = ahb_slave_config::WAIT_ZERO;  // â KEY LINE!
    
    uvm_config_db#(ahb_slave_config)::set(this, "slave_agent*", "cfg", slave_cfg);
    
    `uvm_info("ENV", "Configured slave with ZERO wait states", UVM_MEDIUM)
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        // Wait for reset to be released
       // wait(vif.HRESETn == 1'b1);
      //  repeat(20) @(posedge vif.HCLK);
       
 	#200ns;

        `uvm_info("TEST", "Starting test sequence after reset...", UVM_LOW)
        
        run_test_sequence();
        
        // Settle time
       // repeat(50) @(posedge vif.HCLK);
        #500ns;
        phase.drop_objection(this);
    endtask
    
    virtual task run_test_sequence();
        // Override in derived tests
    endtask

endclass

`endif
