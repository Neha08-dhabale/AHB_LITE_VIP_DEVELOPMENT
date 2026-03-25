`ifndef AHB_LITE_READ_SEQ_SV
`define AHB_LITE_READ_SEQ_SV

class ahb_lite_read_seq extends ahb_lite_base_seq;
    
    `uvm_object_utils(ahb_lite_read_seq)
    
    rand bit [31:0] start_addr;
    rand int num_reads;
    
    constraint c_addr { start_addr[1:0] == 2'b00; }
    constraint c_num { num_reads inside {[8:32]}; }
    
    function new(string name = "ahb_lite_read_seq");
        super.new(name);
    endfunction
    
    task body();
    bit [31:0] addr;
    ahb_lite_seq_item req;
    
    `uvm_info("SEQ", $sformatf("Starting %0d pipelined reads from 0x%08h", 
              num_reads, start_addr), UVM_LOW)
    
    for (int i = 0; i < num_reads; i++) begin
        addr = start_addr + (i * 4);
        
        // Create transaction
        req = ahb_lite_seq_item::type_id::create($sformatf("req_%0d", i));
        
        start_item(req);
        
        // Use your make_read() function - it sets all fields correctly!
        req.make_read(addr);
        
        finish_item(req);
    end
    
    `uvm_info("SEQ", "Pipelined sequence complete", UVM_LOW)
endtask
endclass : ahb_lite_read_seq

`endif
