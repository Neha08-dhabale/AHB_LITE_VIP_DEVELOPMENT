package ahb_slave_pkg;
    
    import uvm_pkg::*;
    import ahb_lite_pkg::*;
    `include "uvm_macros.svh"
    
    `include "ahb_slave_memory.sv"
    `include "ahb_slave_config.sv"
    `include "ahb_slave_seq_item.sv"
    `include "ahb_slave_sequencer.sv"
    `include "ahb_slave_driver.sv"
    `include "ahb_slave_monitor.sv"
    `include "ahb_slave_agent.sv"
    
endpackage : ahb_slave_pkg
