`ifndef AHB_LITE_CONFIG_SV
`define AHB_LITE_CONFIG_SV

class ahb_lite_config extends uvm_object;
    
    bit is_active = 1;
    ahb_agent_mode_e agent_mode = AHB_MASTER;
    
    int addr_width = 32;
    int data_width = 32;
    int max_wait_cycles = 200;
    
    bit enable_coverage = 1;
    bit enable_protocol_checks = 1;
    
    bit [31:0] addr_min = 32'h0000_0000;
    bit [31:0] addr_max = 32'h00FF_FFFF;
    
    `uvm_object_utils_begin(ahb_lite_config)
        `uvm_field_int(is_active, UVM_DEFAULT)
        `uvm_field_enum(ahb_agent_mode_e, agent_mode, UVM_DEFAULT)
        `uvm_field_int(enable_coverage, UVM_DEFAULT)
        `uvm_field_int(enable_protocol_checks, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "ahb_lite_config");
        super.new(name);
    endfunction

endclass : ahb_lite_config

`endif



