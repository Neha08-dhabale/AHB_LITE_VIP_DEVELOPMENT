`ifndef AHB_SLAVE_MONITOR_SV
`define AHB_SLAVE_MONITOR_SV

class ahb_slave_monitor extends uvm_monitor;
    
    `uvm_component_utils(ahb_slave_monitor)
    
    virtual slave_ahb_if vif;
    uvm_analysis_port #(ahb_slave_seq_item) ap;
    
    bit [31:0] addr_phase_addr;
    bit        addr_phase_write;
    bit [1:0]  addr_phase_htrans;
    bit        addr_phase_valid;
    bit        in_data_phase;
    int        wait_count;
    bit [31:0] captured_wdata;
    
    function new(string name = "ahb_slave_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual slave_ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction
    
    task run_phase(uvm_phase phase);
        ahb_slave_seq_item txn;
        bit captured_hresp;
        
        forever begin
            @(vif.monitor_cb);  //  CHANGED: Use monitor_cb, not slave_cb
            
            if (!vif.HRESETn) begin
                addr_phase_valid = 0;
                in_data_phase = 0;
                wait_count = 0;
                continue;
            end
            
            // STATE 1: Data phase completes
            if (in_data_phase && vif.monitor_cb.HREADYOUT) begin  // â monitor_cb
                captured_hresp = vif.monitor_cb.HRESP;  // â monitor_cb
                
                txn = ahb_slave_seq_item::type_id::create("txn");
                txn.addr = addr_phase_addr;
                txn.write = addr_phase_write;
                txn.trans_type = addr_phase_htrans;
                txn.wait_cycles = wait_count;
                txn.return_error = captured_hresp;
                
                if (captured_hresp) begin
                    if (addr_phase_write)
                        txn.write_data = 32'hXXXXXXXX;
                    else
                        txn.read_data = 32'hXXXXXXXX;
                    
                    `uvm_info("SLAVE_MON", $sformatf("Observed ERROR: %s [0x%08h] = INVALID (waits=%0d)",
                              addr_phase_write ? "WRITE" : "READ",
                              addr_phase_addr, wait_count), UVM_MEDIUM)
                end else begin
                    if (addr_phase_write)
                        txn.write_data = captured_wdata;
                    else
                        txn.read_data = vif.monitor_cb.HRDATA;  // â monitor_cb
                    
                    `uvm_info("SLAVE_MON", $sformatf("Observed: %s [0x%08h] = 0x%08h (waits=%0d)",
                              addr_phase_write ? "WRITE" : "READ",
                              addr_phase_addr, 
                              addr_phase_write ? txn.write_data : txn.read_data,
                              wait_count), UVM_MEDIUM)
                end
                
                ap.write(txn);
                
                addr_phase_valid = 0;
                in_data_phase = 0;
                wait_count = 0;
                
                if (vif.monitor_cb.HSEL && vif.monitor_cb.HTRANS[1] && vif.monitor_cb.HREADY) begin  // â monitor_cb
                    addr_phase_addr = vif.monitor_cb.HADDR;
                    addr_phase_write = vif.monitor_cb.HWRITE;
                    addr_phase_htrans = vif.monitor_cb.HTRANS;
                    addr_phase_valid = 1;
                    in_data_phase = 0;
                end
                
            end else if (addr_phase_valid && !in_data_phase) begin
                in_data_phase = 1;
                wait_count = 0;
                if (addr_phase_write)
                    captured_wdata = vif.monitor_cb.HWDATA;  // â monitor_cb
                
            end else if (in_data_phase && !vif.monitor_cb.HREADYOUT) begin  // â monitor_cb
                wait_count++;
                
            end else if (!addr_phase_valid &&
                         vif.monitor_cb.HSEL &&      // 
                         vif.monitor_cb.HTRANS[1] && // â monitor_cb
                         vif.monitor_cb.HREADY) begin // â monitor_cb
                addr_phase_addr = vif.monitor_cb.HADDR;    // â monitor_cb
                addr_phase_write = vif.monitor_cb.HWRITE;  // â monitor_cb
                addr_phase_htrans = vif.monitor_cb.HTRANS; // â monitor_cb
                addr_phase_valid = 1;
                in_data_phase = 0;
                wait_count = 0;
            end
        end
    endtask
    
endclass

`endif
