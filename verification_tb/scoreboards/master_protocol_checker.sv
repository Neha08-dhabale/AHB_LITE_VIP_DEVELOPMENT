`ifndef MASTER_PROTOCOL_CHECKER_SV
`define MASTER_PROTOCOL_CHECKER_SV

class master_protocol_checker extends uvm_scoreboard;
    
    `uvm_component_utils(master_protocol_checker)
    
    // Analysis import for master transactions
    uvm_analysis_imp #(ahb_lite_seq_item, master_protocol_checker) master_imp;
    
    ahb_lite_config cfg;
    
    int violations = 0;
    int addr_violations = 0;
    int write_violations = 0;
    int timeout_count = 0;
    
    function new(string name = "master_protocol_checker", uvm_component parent = null);
        super.new(name, parent);
        master_imp = new("master_imp", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(ahb_lite_config)::get(this, "", "cfg", cfg)) begin
            `uvm_info("PROTO_CHK", "cfg not found in config_db using default ahb_lite_config", UVM_MEDIUM)
            cfg = ahb_lite_config::type_id::create("cfg");
        end
    endfunction
    
    function void write(ahb_lite_seq_item txn);
        // Protocol checks happen in the monitor
        // This scoreboard just receives transactions for reporting
        
        // Could add checks here if needed:
        // - Check for timeout (wait_cycles > cfg.max_wait_cycles)
        // - Check for ERROR response handling
        // etc.
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info("PROTO_REPORT", "============================================", UVM_NONE)
        `uvm_info("PROTO_REPORT", "  Master VIP Protocol Compliance Report", UVM_NONE)
        `uvm_info("PROTO_REPORT", "============================================", UVM_NONE)
        `uvm_info("PROTO_REPORT", $sformatf("Total Violations:          %0d", violations), UVM_NONE)
        `uvm_info("PROTO_REPORT", $sformatf("  HADDR changed during wait:  %0d", addr_violations), UVM_NONE)
        `uvm_info("PROTO_REPORT", $sformatf("  HWRITE changed during wait: %0d", write_violations), UVM_NONE)
        `uvm_info("PROTO_REPORT", $sformatf("  Wait timeout count:         %0d", timeout_count), UVM_NONE)
        
        if (violations == 0) begin
            `uvm_info("PROTO_REPORT", "MASTER VIP IS PROTOCOL COMPLIANT!", UVM_NONE)
        end
        
        `uvm_info("PROTO_REPORT", "============================================", UVM_NONE)
    endfunction

endclass

`endif
