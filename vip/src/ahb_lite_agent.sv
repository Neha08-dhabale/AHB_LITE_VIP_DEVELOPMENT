`ifndef AHB_LITE_AGENT_SV
`define AHB_LITE_AGENT_SV

class ahb_lite_agent extends uvm_agent;
    
    `uvm_component_utils(ahb_lite_agent)
    
    ahb_lite_driver      driver;
    ahb_lite_monitor     monitor;
    ahb_lite_sequencer   sequencer;
    ahb_lite_config      cfg;
    uvm_analysis_port #(ahb_lite_seq_item) ap;
    
    function new(string name = "ahb_lite_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(ahb_lite_config)::get(this, "", "cfg", cfg)) begin
            `uvm_info("NOCONFIG", "Using default config", UVM_LOW)
            cfg = ahb_lite_config::type_id::create("cfg");
        end
        
        monitor = ahb_lite_monitor::type_id::create("monitor", this);
        
        if (cfg.is_active == UVM_ACTIVE) begin
            driver = ahb_lite_driver::type_id::create("driver", this);
            sequencer = ahb_lite_sequencer::type_id::create("sequencer", this);
        end
        
        uvm_config_db#(ahb_lite_config)::set(this, "*", "cfg", cfg);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (cfg.is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
        ap = monitor.ap;
    endfunction

endclass : ahb_lite_agent

`endif

