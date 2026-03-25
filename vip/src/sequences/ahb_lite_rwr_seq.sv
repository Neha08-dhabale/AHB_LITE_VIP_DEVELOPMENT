`ifndef AHB_LITE_RWR_SEQ_SV
`define AHB_LITE_RWR_SEQ_SV

class ahb_lite_rwr_seq extends ahb_lite_base_seq;
    
    `uvm_object_utils(ahb_lite_rwr_seq)
    
    rand bit [31:0] test_addr;
    rand bit [31:0] write_data;
    bit [31:0] read_data1, read_data2;
    
    constraint c_addr { test_addr[1:0] == 2'b00; }
    
    function new(string name = "ahb_lite_rwr_seq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info("SEQ", $sformatf("RWR Test at 0x%08h", test_addr), UVM_LOW)
        
        // Read initial value
        send_read(test_addr, read_data1);
        `uvm_info("SEQ", $sformatf("Initial read: 0x%08h", read_data1), UVM_MEDIUM)
        
        // Write new value
        send_write(test_addr, write_data);
        `uvm_info("SEQ", $sformatf("Wrote: 0x%08h", write_data), UVM_MEDIUM)
        
        // Read back
        send_read(test_addr, read_data2);
        `uvm_info("SEQ", $sformatf("Read back: 0x%08h", read_data2), UVM_MEDIUM)
        
        // Check
        if (read_data2 === write_data) begin
            `uvm_info("SEQ", "â RWR Test PASSED", UVM_LOW)
        end else begin
            `uvm_error("SEQ", $sformatf("RWR Test FAILED: Expected 0x%08h, Got 0x%08h", 
                      write_data, read_data2))
        end
    endtask

endclass : ahb_lite_rwr_seq

`endif
