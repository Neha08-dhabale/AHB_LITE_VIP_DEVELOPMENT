`ifndef AHB_LITE_DRIVER_SV
`define AHB_LITE_DRIVER_SV

class ahb_lite_driver extends uvm_driver #(ahb_lite_seq_item);
    
    `uvm_component_utils(ahb_lite_driver)
    
    virtual master_ahb_if vif;
    ahb_lite_config cfg;
    
    function new(string name = "ahb_lite_driver", uvm_component parent = null);
        super.new(name, parent);  // â FIXED
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual master_ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
        if (!uvm_config_db#(ahb_lite_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NOCFG", "Configuration not found")
    endfunction
    
    task run_phase(uvm_phase phase);
        reset_signals();
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    task drive_transaction(ahb_lite_seq_item txn);
        `uvm_info("DRIVER", $sformatf("Driving %s to 0x%08h", 
                  txn.write ? "WRITE" : "READ", txn.addr), UVM_MEDIUM)
        
        // Address phase
        wait(vif.master_cb.HREADY);
        @(vif.master_cb);
        
        vif.master_cb.HADDR <= txn.addr;
        vif.master_cb.HTRANS <= txn.trans_type;
        vif.master_cb.HWRITE <= txn.write;
        vif.master_cb.HSIZE <= txn.size;
        vif.master_cb.HBURST <= txn.burst;
        vif.master_cb.HPROT <= txn.prot;
        vif.master_cb.HSEL <= 1'b1;
        
        // Data phase
        @(vif.master_cb);
        
        if (txn.write)
            vif.master_cb.HWDATA <= txn.data;
        
        // Wait for slave to be ready
        txn.wait_cycles = 0;
        while (!vif.master_cb.HREADYOUT) begin
            @(vif.master_cb);
            txn.wait_cycles++;
            if (txn.wait_cycles > cfg.max_wait_cycles) begin
                `uvm_error("DRIVER", "HREADYOUT timeout")
                break;
            end
        end
        
        // Sample response
        txn.resp = ahb_hresp_e'(vif.master_cb.HRESP);
        
        // For reads: sample data
        if (!txn.write) begin
            if (txn.resp == OKAY) begin
                txn.data = vif.master_cb.HRDATA;
                `uvm_info("DRIVER", $sformatf("Read 0x%08h from 0x%08h (waits=%0d)", 
                          txn.data, txn.addr, txn.wait_cycles), UVM_HIGH)
            end else begin
                txn.data = 32'hXXXXXXXX;
                `uvm_info("DRIVER", "ERROR response - data invalid", UVM_MEDIUM)
            end
        end else begin
            `uvm_info("DRIVER", $sformatf("Wrote 0x%08h to 0x%08h (waits=%0d)", 
                      txn.data, txn.addr, txn.wait_cycles), UVM_HIGH)
        end
        
        `uvm_info("DRIVER", $sformatf("Complete: resp=%s", txn.resp.name()), UVM_HIGH)
    endtask
    
    task reset_signals();
        vif.master_cb.HADDR <= '0;
        vif.master_cb.HTRANS <= IDLE;
        vif.master_cb.HWRITE <= '0;
        vif.master_cb.HSIZE <= SIZE_WORD;
        vif.master_cb.HBURST <= SINGLE;
        vif.master_cb.HPROT <= '0;
        vif.master_cb.HWDATA <= '0;
        vif.master_cb.HSEL <= '0;
    endtask
endclass

`endif
