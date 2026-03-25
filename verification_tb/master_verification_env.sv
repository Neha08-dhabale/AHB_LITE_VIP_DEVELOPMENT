`ifndef MASTER_VERIFICATION_ENV_SV
`define MASTER_VERIFICATION_ENV_SV

class master_verification_env extends uvm_env;
    
    `uvm_component_utils(master_verification_env)
    
    // Master VIP (DUT - what we're testing!)
    ahb_lite_agent master_agent;
    ahb_lite_config master_cfg;
    
    // Slave VIP (programmable responder)
    ahb_slave_agent slave_agent;
    ahb_slave_config slave_cfg;
    ahb_slave_memory slave_mem;
    
    // Scoreboards
    master_protocol_checker protocol_sb;
    master_functional_checker func_sb;
    
    function new(string name = "master_verification_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Configure MASTER VIP (as DUT)
        master_cfg = ahb_lite_config::type_id::create("master_cfg");
        master_cfg.is_active = UVM_ACTIVE;
        master_cfg.agent_mode = AHB_MASTER;
        master_cfg.max_wait_cycles = 200;
        uvm_config_db#(ahb_lite_config)::set(this, "master_agent*", "cfg", master_cfg);
        
        // Configure SLAVE VIP
        slave_cfg = ahb_slave_config::type_id::create("slave_cfg");
        slave_cfg.is_active = UVM_ACTIVE;
        // Default: random waits 0-5 cycles
        slave_cfg.wait_mode = ahb_slave_config::WAIT_RANDOM;
        slave_cfg.min_wait = 0;
        slave_cfg.max_wait = 5;
        uvm_config_db#(ahb_slave_config)::set(this, "slave_agent*", "cfg", slave_cfg);
        
        // Create memory model
        slave_mem = ahb_slave_memory::type_id::create("slave_mem");
        slave_mem.load_pattern(32'h1000, 256, 32'hA5A50000);  // Test pattern
        uvm_config_db#(ahb_slave_memory)::set(this, "slave_agent*", "mem", slave_mem);
        
        // Create agents
        master_agent = ahb_lite_agent::type_id::create("master_agent", this);
        slave_agent = ahb_slave_agent::type_id::create("slave_agent", this);
        
        // Create scoreboards
        protocol_sb = master_protocol_checker::type_id::create("protocol_sb", this);
        func_sb = master_functional_checker::type_id::create("func_sb", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect master monitor to scoreboards
        master_agent.ap.connect(protocol_sb.master_imp);
        master_agent.ap.connect(func_sb.master_export);
        
        // Connect slave monitor to scoreboards
        slave_agent.ap.connect(func_sb.slave_export);
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("ENV", "Master VIP Verification Environment Built", UVM_LOW)
        `uvm_info("ENV", $sformatf("  Master Agent: %s", master_agent.get_full_name()), UVM_LOW)
        `uvm_info("ENV", $sformatf("  Slave Agent:  %s", slave_agent.get_full_name()), UVM_LOW)
    endfunction

endclass

`endif
