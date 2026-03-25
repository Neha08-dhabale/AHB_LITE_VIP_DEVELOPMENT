`ifndef AHB_SLAVE_DRIVER_SV
`define AHB_SLAVE_DRIVER_SV

class ahb_slave_driver extends uvm_driver #(ahb_slave_seq_item);
    
    `uvm_component_utils(ahb_slave_driver)
    
   // virtual ahb_lite_if vif;
	virtual slave_ahb_if vif;
    ahb_slave_config cfg;
    ahb_slave_memory mem;
    
    function new(string name = "ahb_slave_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        //if (!uvm_config_db#(virtual ahb_lite_if)::get(this, "", "vif", vif))
	if (!uvm_config_db#(virtual slave_ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
        
        if (!uvm_config_db#(ahb_slave_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NOCFG", "Slave config not found")
        
        if (!uvm_config_db#(ahb_slave_memory)::get(this, "", "mem", mem))
            `uvm_fatal("NOMEM", "Slave memory not found")
    endfunction
    
    task run_phase(uvm_phase phase);
        @(posedge vif.HRESETn);
        repeat(2) @(vif.slave_cb);
        
        `uvm_info("SLAVE_DRV", "Slave driver starting...", UVM_MEDIUM)
        
        vif.slave_cb.HREADYOUT <= 1'b1;
        vif.slave_cb.HRESP <= 1'b0;
        vif.slave_cb.HRDATA <= 32'h0;
        
        fork
            capture_and_respond();
        join
    endtask
    
   task capture_and_respond();
    bit [31:0] pending_addr;
    bit        pending_write;
    bit        have_pending;
    int        wait_cycles;
    bit        return_error;
    bit [31:0] rdata;
    
    // Default: Always ready
    vif.slave_cb.HREADYOUT <= 1'b1;
    vif.slave_cb.HRESP <= 1'b0;
    
    forever begin
        @(vif.slave_cb);
        
        // ========================================
        // STATE 1: Complete pending data phase
        // ========================================
        if (have_pending) begin
            
            // ERROR RESPONSE: Two-cycle protocol
            if (return_error) begin
                // Cycle 1: HRESP=1, HREADYOUT=0
                vif.slave_cb.HRESP <= 1'b1;
                vif.slave_cb.HREADYOUT <= 1'b0;
                vif.slave_cb.HRDATA <= 32'hDEADBEEF;
                
                `uvm_info("SLAVE_DRV", $sformatf("ERROR %s [0x%08h] cycle 1/2", 
                          pending_write ? "WR" : "RD", pending_addr), UVM_MEDIUM)
                
                @(vif.slave_cb);
                
                // Cycle 2: HRESP=1, HREADYOUT=1
                vif.slave_cb.HRESP <= 1'b1;
                vif.slave_cb.HREADYOUT <= 1'b1;
                
                `uvm_info("SLAVE_DRV", $sformatf("ERROR %s [0x%08h] cycle 2/2", 
                          pending_write ? "WR" : "RD", pending_addr), UVM_MEDIUM)
                
                // Clear pending and return to normal
                have_pending = 0;
                return_error = 0;
                
                // Next cycle: clear error
                @(vif.slave_cb);
                vif.slave_cb.HRESP <= 1'b0;
                vif.slave_cb.HREADYOUT <= 1'b1;
                
            // NORMAL RESPONSE: Write or read
            end else begin
                if (pending_write) begin
                    bit [31:0] wdata = vif.slave_cb.HWDATA;
                    mem.write(pending_addr, wdata);
                    `uvm_info("SLAVE_DRV", $sformatf("WRITE [0x%08h]=0x%08h", 
                              pending_addr, wdata), UVM_MEDIUM)
                end else begin
                    rdata = mem.read(pending_addr);
                    vif.slave_cb.HRDATA <= rdata;
                    `uvm_info("SLAVE_DRV", $sformatf("READ  [0x%08h]=0x%08h", 
                              pending_addr, rdata), UVM_MEDIUM)
                end
                
                vif.slave_cb.HREADYOUT <= 1'b1;
                vif.slave_cb.HRESP <= 1'b0;
                have_pending = 0;
            end
        end
        
        // ========================================
        // STATE 2: Capture new address phase
        // ========================================
        if (vif.slave_cb.HSEL && vif.slave_cb.HTRANS[1] && vif.slave_cb.HREADY) begin
            pending_addr = vif.slave_cb.HADDR;
            pending_write = vif.slave_cb.HWRITE;
            wait_cycles = cfg.get_wait_cycles();
            return_error = cfg.should_error(pending_addr);
            have_pending = 1;
            
            `uvm_info("SLAVE_DRV", $sformatf("Captured: %s [0x%08h] waits=%0d err=%0b", 
                      pending_write ? "WR" : "RD", pending_addr, wait_cycles, return_error), UVM_HIGH)
            
            // Handle wait states (only if no error)
            if (wait_cycles > 0 && !return_error) begin
                @(vif.slave_cb);
                vif.slave_cb.HREADYOUT <= 1'b0;
                vif.slave_cb.HRESP <= 1'b0;
                
                repeat(wait_cycles - 1) @(vif.slave_cb);
                
                @(vif.slave_cb);
                vif.slave_cb.HREADYOUT <= 1'b1;
                vif.slave_cb.HRESP <= 1'b0;
            end
            
        end else if (!have_pending) begin
            // No transaction - ensure ready
            vif.slave_cb.HREADYOUT <= 1'b1;
            vif.slave_cb.HRESP <= 1'b0;
        end
    end
endtask
endclass

`endif
