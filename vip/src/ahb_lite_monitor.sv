`ifndef AHB_LITE_MONITOR_SV
`define AHB_LITE_MONITOR_SV

class ahb_lite_monitor extends uvm_monitor;
    
    `uvm_component_utils(ahb_lite_monitor)
    
   // virtual ahb_lite_if vif;
    virtual master_ahb_if vif;
    ahb_lite_config cfg;
    uvm_analysis_port #(ahb_lite_seq_item) ap;
    
    // State tracking
    bit               addr_phase_valid;
    bit               in_data_phase;
    bit [31:0]        captured_addr;
    bit               captured_write;
    ahb_htrans_e      captured_trans;
    ahb_hsize_e       captured_size;
    ahb_hburst_e      captured_burst;
    bit [3:0]         captured_prot;
    bit [31:0]        captured_wdata;  // NEW: capture write data early!
    
    function new(string name = "ahb_lite_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //if (!uvm_config_db#(virtual ahb_lite_if)::get(this, "", "vif", vif))
	if (!uvm_config_db#(virtual master_ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
        if (!uvm_config_db#(ahb_lite_config)::get(this, "", "cfg", cfg))
            cfg = ahb_lite_config::type_id::create("cfg");
    endfunction

    task run_phase(uvm_phase phase);
        int wait_count;

        forever begin
            @(vif.monitor_cb);

            if (!vif.HRESETn) begin
                addr_phase_valid = 0;
                in_data_phase = 0;
                wait_count = 0;
                continue;
            end

            // STATE 1: Data phase completion
            if (in_data_phase && vif.monitor_cb.HREADYOUT) begin
                ahb_lite_seq_item txn = ahb_lite_seq_item::type_id::create("txn");
                txn.addr = captured_addr;
                txn.write = captured_write;
                txn.trans_type = captured_trans;
                txn.size = captured_size;
                txn.burst = captured_burst;
                txn.prot = captured_prot;
                txn.resp = ahb_hresp_e'(vif.monitor_cb.HRESP);
                txn.wait_cycles = wait_count;
                
                // CRITICAL: For writes, use CAPTURED data (from data phase start)
                // For reads, sample HRDATA NOW (slave just drove it)
                if (captured_write)
                    txn.data = captured_wdata;  // Use captured value!
                else
                    txn.data = vif.monitor_cb.HRDATA;
                
                ap.write(txn);

                `uvm_info("MONITOR", $sformatf("Collected: %s 0x%08h = 0x%08h (waits=%0d)",
                          captured_write ? "WRITE" : " READ",
                          txn.addr, txn.data, txn.wait_cycles), UVM_MEDIUM)

                // Clear state
                addr_phase_valid = 0;
                in_data_phase = 0;
                wait_count = 0;

                // Check for pipelined new address
                if (vif.monitor_cb.HSEL &&
                    vif.monitor_cb.HTRANS[1] &&
                    vif.monitor_cb.HREADY) begin
                    captured_addr = vif.monitor_cb.HADDR;
                    captured_write = vif.monitor_cb.HWRITE;
                    captured_trans = ahb_htrans_e'(vif.monitor_cb.HTRANS);
                    captured_size = ahb_hsize_e'(vif.monitor_cb.HSIZE);
                    captured_burst = ahb_hburst_e'(vif.monitor_cb.HBURST);
                    captured_prot = vif.monitor_cb.HPROT;
                    addr_phase_valid = 1;
                    in_data_phase = 0;
                end
                
            // STATE 2: Entering data phase (capture HWDATA for writes!)
            end else if (addr_phase_valid && !in_data_phase) begin
                in_data_phase = 1;
                wait_count = 0;
                
                // CRITICAL: Capture HWDATA at START of data phase!
                if (captured_write)
                    captured_wdata = vif.monitor_cb.HWDATA;
                
            // STATE 3: Counting waits
            end else if (in_data_phase && !vif.monitor_cb.HREADYOUT) begin
                wait_count++;
                
            // STATE 4: Fresh address phase
            end else if (!addr_phase_valid &&
                         vif.monitor_cb.HSEL &&
                         vif.monitor_cb.HTRANS[1] &&
                         vif.monitor_cb.HREADY) begin
                captured_addr = vif.monitor_cb.HADDR;
                captured_write = vif.monitor_cb.HWRITE;
                captured_trans = ahb_htrans_e'(vif.monitor_cb.HTRANS);
                captured_size = ahb_hsize_e'(vif.monitor_cb.HSIZE);
                captured_burst = ahb_hburst_e'(vif.monitor_cb.HBURST);
                captured_prot = vif.monitor_cb.HPROT;
                addr_phase_valid = 1;
                in_data_phase = 0;
                wait_count = 0;
            end
        end
    endtask

endclass

`endif
