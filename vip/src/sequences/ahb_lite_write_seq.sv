`ifndef AHB_LITE_WRITE_SEQ_SV
`define AHB_LITE_WRITE_SEQ_SV

class ahb_lite_write_seq extends ahb_lite_base_seq;
    
    `uvm_object_utils(ahb_lite_write_seq)
    
    rand bit [31:0] start_addr;
    rand int num_writes;
    rand bit [31:0] data_pattern;
    
    constraint c_addr { 
        start_addr[1:0] == 2'b00; 
    }
    
    constraint c_num { 
        num_writes inside {[1:100]}; 
    }
    
    function new(string name = "ahb_lite_write_seq");
        super.new(name);
    endfunction
    
    task body();
        bit [31:0] addr, data;
        
        `uvm_info("SEQ", $sformatf("Starting %0d writes from 0x%08h", 
                  num_writes, start_addr), UVM_LOW)
        
        for (int i = 0; i < num_writes; i++) begin
            addr = start_addr + (i * 4);
            data = data_pattern + i;
            send_write(addr, data);
        end
        
        `uvm_info("SEQ", "Write sequence complete", UVM_LOW)
    endtask

endclass

`endif
