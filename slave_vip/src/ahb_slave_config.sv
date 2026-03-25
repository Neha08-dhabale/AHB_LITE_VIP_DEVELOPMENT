`ifndef AHB_SLAVE_CONFIG_SV
`define AHB_SLAVE_CONFIG_SV

class ahb_slave_config extends uvm_object;
    
    `uvm_object_utils(ahb_slave_config)
    
    // Basic config
    bit is_active = 1;
    
    // Wait state configuration
    typedef enum {
        WAIT_ZERO,       // Always 0 wait states (fast)
        WAIT_FIXED,      // Fixed number of waits
        WAIT_RANDOM,     // Random in range
        WAIT_PATTERN     // Specific pattern
    } wait_mode_e;
    
    wait_mode_e wait_mode = WAIT_ZERO;
    int fixed_wait_value = 0;
    int min_wait = 0;
    int max_wait = 5;
    int wait_pattern[$];  // For patterned waits
    
    // Error injection
    bit enable_errors = 0;
    real error_probability = 0.0;  // 0.0 to 1.0
    bit [31:0] error_addr_list[$];
    
    // Protocol checking
    bit check_addr_stable = 1;
    bit check_write_stable = 1;
    
    function new(string name = "ahb_slave_config");
        super.new(name);
    endfunction
    
    // Add error address
    virtual function void add_error_addr(bit [31:0] addr);
        error_addr_list.push_back(addr);
        enable_errors = 1;
        `uvm_info("SLAVE_CFG", $sformatf("Added error address: 0x%08h", addr), UVM_MEDIUM)
    endfunction
    
    // Check if should return error
    virtual function bit should_error(bit [31:0] addr);
        if (!enable_errors) return 0;
        
        // Check specific addresses
        foreach (error_addr_list[i]) begin
            if (error_addr_list[i] == addr) return 1;
        end
        
        // Random error injection
        if (error_probability > 0.0) begin
            int rand_val = $urandom_range(0, 1000);
            if ((rand_val / 1000.0) < error_probability) return 1;
        end
        
        return 0;
    endfunction
    
    // Get wait cycles based on mode
    virtual function int get_wait_cycles();
        int cycles;
        
        case (wait_mode)
            WAIT_ZERO: cycles = 0;
            WAIT_FIXED: cycles = fixed_wait_value;
            WAIT_RANDOM: cycles = $urandom_range(max_wait, min_wait);
            WAIT_PATTERN: begin
                if (wait_pattern.size() > 0) begin
                    cycles = wait_pattern[0];
                    wait_pattern.push_back(wait_pattern.pop_front());  // Rotate
                end else begin
                    cycles = 0;
                end
            end
            default: cycles = 0;
        endcase
        
        return cycles;
    endfunction

endclass
`endif
