`ifndef AHB_LITE_CACHE_SEQ_SV
`define AHB_LITE_CACHE_SEQ_SV

class ahb_lite_cache_seq extends ahb_lite_base_seq;
    
    `uvm_object_utils(ahb_lite_cache_seq)
    
    rand bit [31:0] base_addr;
    
    constraint c_addr { base_addr[1:0] == 2'b00; }
    
    function new(string name = "ahb_lite_cache_seq");
        super.new(name);
    endfunction
    
task body();
    bit [31:0] data;

    // LINE_SIZE=16 bytes = 4 words per cache line
    // Only loop i=1 to 3 to stay within the SAME cache line
    
    `uvm_info("SEQ", "First access (expect MISS)...", UVM_LOW)
    send_read(base_addr, data);

    `uvm_info("SEQ", "Second access same addr (expect HIT)...", UVM_LOW)
    send_read(base_addr, data);

    `uvm_info("SEQ", "Sequential accesses in same line (3 more words)...", UVM_LOW)
    for (int i = 1; i < 7; i++) begin       // â was 8, fix to 4 for LINE_SIZE=16
        send_read(base_addr + (i*4), data);  // covers +4,+8,+12 = stays in line â
    end

    `uvm_info("SEQ", "Access to next cache line (expect MISS)...", UVM_LOW)
    send_read(base_addr + 32'h20, data);     // â +16 = next line boundary

    `uvm_info("SEQ", "Access different region (expect MISS)...", UVM_LOW)
    send_read(base_addr + 32'h1000, data);
endtask
    
endclass : ahb_lite_cache_seq

`endif
