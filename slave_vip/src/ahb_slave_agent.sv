`ifndef AHB_SLAVE_AGENT_SV
`define AHB_SLAVE_AGENT_SV

class ahb_slave_agent extends uvm_agent;
    
    `uvm_component_utils(ahb_slave_agent)
    
    ahb_slave_driver     driver;
    ahb_slave_monitor    monitor;
    ahb_slave_sequencer  sequencer;
    ahb_slave_config     cfg;
    ahb_slave_memory     mem;
    
    uvm_analysis_port #(ahb_slave_seq_item) ap;
    
    function new(string name = "ahb_slave_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(ahb_slave_config)::get(this, "", "cfg", cfg)) begin
            `uvm_info("AGENT", "Creating default slave config", UVM_MEDIUM)
            cfg = ahb_slave_config::type_id::create("cfg");
        end
        
        if (!uvm_config_db#(ahb_slave_memory)::get(this, "", "mem", mem)) begin
            `uvm_info("AGENT", "Creating default slave memory", UVM_MEDIUM)
            mem = ahb_slave_memory::type_id::create("mem");
        end
        
        monitor = ahb_slave_monitor::type_id::create("monitor", this);
        
        if (cfg.is_active == UVM_ACTIVE) begin
            driver = ahb_slave_driver::type_id::create("driver", this);
            sequencer = ahb_slave_sequencer::type_id::create("sequencer", this);
        end
        
        uvm_config_db#(ahb_slave_config)::set(this, "*", "cfg", cfg);
        uvm_config_db#(ahb_slave_memory)::set(this, "*", "mem", mem);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if (cfg.is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
        
        ap = monitor.ap;
    endfunction

endclass

`endif
