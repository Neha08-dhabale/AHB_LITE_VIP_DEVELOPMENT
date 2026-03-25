`ifndef AHB_LITE_RANDOM_SEQ_SV
`define AHB_LITE_RANDOM_SEQ_SV

class ahb_lite_random_seq extends ahb_lite_base_seq;
    
    `uvm_object_utils(ahb_lite_random_seq)
    
    rand int num_transactions;
    rand bit [31:0] addr_min;
    rand bit [31:0] addr_max;
    
    constraint c_num { num_transactions inside {[20:50]}; }
    constraint c_addr_range { 
        addr_min[1:0] == 2'b00;
        addr_max[1:0] == 2'b00;
        addr_max > addr_min;
    }
    
    function new(string name = "ahb_lite_random_seq");
        super.new(name);
    endfunction
    
    task body();
        bit [31:0] addr, data;
        bit write;
        
        `uvm_info("SEQ", $sformatf("Random sequence: %0d transactions", 
                  num_transactions), UVM_LOW)
        
        for (int i = 0; i < num_transactions; i++) begin
            // Random address in range
            addr = $urandom_range(addr_max, addr_min);
            addr[1:0] = 2'b00;  // Word-aligned
            
            // Random read or write
            write = $urandom_range(1, 0);
            
            if (write) begin
                data = $urandom();
                send_write(addr, data);
            end else begin
                send_read(addr, data);
            end
        end
        
        `uvm_info("SEQ", "Random sequence complete", UVM_LOW)
    endtask

endclass : ahb_lite_random_seq

`endif

