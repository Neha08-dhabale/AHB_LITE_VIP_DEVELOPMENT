`ifndef TB_ENV_SV
`define TB_ENV_SV

`include "ahb_scoreboard.sv"

class tb_env extends uvm_env;
    
    `uvm_component_utils(tb_env)
    
    ahb_lite_agent  agent;
    ahb_scoreboard  sb;
    ahb_lite_config cfg;
    
    function new(string name = "tb_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        cfg = ahb_lite_config::type_id::create("cfg");
        cfg.is_active = UVM_ACTIVE;
        cfg.agent_mode = AHB_MASTER;
        cfg.enable_protocol_checks = 1;
        cfg.max_wait_cycles = 200;
        
        uvm_config_db#(ahb_lite_config)::set(this, "*", "cfg", cfg);
        
        agent = ahb_lite_agent::type_id::create("agent", this);
        sb = ahb_scoreboard::type_id::create("sb", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.ap.connect(sb.ap_imp);
    endfunction

endclass : tb_env

`endif
