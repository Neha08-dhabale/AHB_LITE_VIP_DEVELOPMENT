`ifndef MASTER_FUNCTIONAL_CHECKER_SV
`define MASTER_FUNCTIONAL_CHECKER_SV

class master_functional_checker extends uvm_scoreboard;
    
    `uvm_component_utils(master_functional_checker)
    
    uvm_analysis_export #(ahb_lite_seq_item) master_export;
    uvm_analysis_export #(ahb_slave_seq_item) slave_export;
    
    uvm_tlm_analysis_fifo #(ahb_lite_seq_item) master_fifo;
    uvm_tlm_analysis_fifo #(ahb_slave_seq_item) slave_fifo;
    
    int reads = 0;
    int writes = 0;
    int errors = 0;
    int mismatches = 0;
    int match_count = 0;
    
    function new(string name = "master_functional_checker", uvm_component parent = null);
        super.new(name, parent);
        master_export = new("master_export", this);
        slave_export = new("slave_export", this);
        master_fifo = new("master_fifo", this);
        slave_fifo = new("slave_fifo", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        master_export.connect(master_fifo.analysis_export);
        slave_export.connect(slave_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        ahb_lite_seq_item  master_txn;
        ahb_slave_seq_item slave_txn;
        bit txn_ok;

        forever begin
            fork
                master_fifo.get(master_txn);
                slave_fifo.get(slave_txn);
            join

            txn_ok = 1;

            // Address check
            if (master_txn.addr !== slave_txn.addr) begin
                `uvm_error("FUNC_CHK", $sformatf(
                    "Address mismatch: M=0x%08h, S=0x%08h",
                    master_txn.addr, slave_txn.addr))
                mismatches++; txn_ok = 0;
            end

            // Direction check
            if (master_txn.write !== slave_txn.write) begin
                `uvm_error("FUNC_CHK", $sformatf(
                    "Type mismatch at 0x%08h", master_txn.addr))
                mismatches++; txn_ok = 0;
            end

            // Error response check (check FIRST before data!)
            if (slave_txn.return_error) begin
                errors++;
                if (master_txn.resp !== ahb_hresp_e'(1)) begin
                    `uvm_error("FUNC_CHK", $sformatf(
                        "Slave signalled ERROR at 0x%08h but master saw OKAY",
                        master_txn.addr))
                    mismatches++;
                    txn_ok = 0;
                end
                // For ERROR transactions, SKIP data comparison (data is invalid!)
                `uvm_info("FUNC_CHK", $sformatf(
                    "ERROR transaction at 0x%08h - data not compared",
                    master_txn.addr), UVM_HIGH)
            end else if (master_txn.resp === ahb_hresp_e'(1)) begin
                `uvm_error("FUNC_CHK", $sformatf(
                    "Spurious ERROR at 0x%08h: master saw ERROR but slave did not flag it",
                    master_txn.addr))
                mismatches++;
                txn_ok = 0;
            end else begin
                // OKAY response - check data
                if (master_txn.write) begin
                    writes++;
                    if (master_txn.data !== slave_txn.write_data) begin
                        `uvm_error("FUNC_CHK", $sformatf(
                            "Write data mismatch at 0x%08h: M=0x%08h, S=0x%08h",
                            master_txn.addr, master_txn.data, slave_txn.write_data))
                        mismatches++; txn_ok = 0;
                    end
                end else begin
                    reads++;
                    if (master_txn.data !== slave_txn.read_data) begin
                        `uvm_error("FUNC_CHK", $sformatf(
                            "Read data mismatch at 0x%08h: M=0x%08h, S=0x%08h",
                            master_txn.addr, master_txn.data, slave_txn.read_data))
                        mismatches++; txn_ok = 0;
                    end
                end
            end

            if (txn_ok) match_count++;
        end
    endtask

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (master_fifo.used() > 0)
            `uvm_error("FUNC_CHK", $sformatf(
                "%0d master txn(s) unmatched slave never responded",
                master_fifo.used()))
        if (slave_fifo.used() > 0)
            `uvm_error("FUNC_CHK", $sformatf(
                "%0d slave txn(s) unmatched master never drove them",
                slave_fifo.used()))
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info("FUNC_REPORT", "============================================", UVM_NONE)
        `uvm_info("FUNC_REPORT", "  Master VIP Functional Report", UVM_NONE)
        `uvm_info("FUNC_REPORT", "============================================", UVM_NONE)
        `uvm_info("FUNC_REPORT", $sformatf("Reads:  %0d", reads), UVM_NONE)
        `uvm_info("FUNC_REPORT", $sformatf("Writes: %0d", writes), UVM_NONE)
        `uvm_info("FUNC_REPORT", $sformatf("Errors: %0d", errors), UVM_NONE)
        `uvm_info("FUNC_REPORT", $sformatf("Matches: %0d", match_count), UVM_NONE)
        `uvm_info("FUNC_REPORT", $sformatf("Mismatches: %0d", mismatches), UVM_NONE)
        
        if (mismatches == 0) begin
            `uvm_info("FUNC_REPORT", "â ALL TRANSACTIONS MATCHED!", UVM_NONE)
        end else begin
            `uvm_error("FUNC_REPORT", "â DATA MISMATCHES DETECTED!")
        end
        
        `uvm_info("FUNC_REPORT", "============================================", UVM_NONE)
    endfunction

endclass

`endif
