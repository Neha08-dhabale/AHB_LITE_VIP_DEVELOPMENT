`ifndef AHB_LITE_BASE_SEQ_SV
`define AHB_LITE_BASE_SEQ_SV

class ahb_lite_base_seq extends uvm_sequence #(ahb_lite_seq_item);
    
    `uvm_object_utils(ahb_lite_base_seq)
    
    function new(string name = "ahb_lite_base_seq");
        super.new(name);
    endfunction
    
    // Helper: Send a read transaction
    task send_read(input bit [31:0] in_addr, output bit [31:0] out_data);
        ahb_lite_seq_item item;
        bit [31:0] addr_val;  // Local variable visible to constraints
        
        addr_val = in_addr;  // Copy parameter to local variable
        
        item = ahb_lite_seq_item::type_id::create("item");
        start_item(item);
        assert(item.randomize() with {
            write      == 1'b0;
            trans_type == NONSEQ;
            addr       == addr_val;  // Use local variable
            size       == SIZE_WORD;
        });
        finish_item(item);
        out_data = item.data;
        `uvm_info("SEQ", $sformatf("Read [0x%08h] = 0x%08h (waits=%0d)", 
                  item.addr, item.data, item.wait_cycles), UVM_HIGH)
    endtask
  
    // Helper: Send a write transaction
    task send_write(input bit [31:0] in_addr, input bit [31:0] in_data);
        ahb_lite_seq_item txn;
        bit [31:0] addr_val;  // Local variable visible to constraints
        bit [31:0] data_val;  // Local variable visible to constraints
        
        addr_val = in_addr;  // Copy parameter to local variable
        data_val = in_data;  // Copy parameter to local variable
        
        txn = ahb_lite_seq_item::type_id::create("txn");
        start_item(txn);
        assert(txn.randomize() with {
            trans_type == NONSEQ;
            write      == 1'b1;
            addr       == addr_val;  // Use local variable
            data       == data_val;  // Use local variable
            size       == SIZE_WORD;
        });
        finish_item(txn);
        `uvm_info("SEQ", $sformatf("Write[0x%08h] = 0x%08h (waits=%0d)", 
                  txn.addr, txn.data, txn.wait_cycles), UVM_HIGH)
    endtask

endclass

`endif
