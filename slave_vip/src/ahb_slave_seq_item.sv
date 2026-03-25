`ifndef AHB_SLAVE_SEQ_ITEM_SV
`define AHB_SLAVE_SEQ_ITEM_SV

class ahb_slave_seq_item extends uvm_sequence_item;
    
    // Response control (what slave will do)
    rand int  wait_cycles;      // How many wait states to inject
    rand bit  return_error;     // Should return ERROR response?
    rand bit  ready_random;     // Random ready pattern?
    
    // Transaction info (observed from master)
    bit [31:0]   addr;
    bit          write;
    bit [31:0]   write_data;
    bit [31:0]   read_data;
    bit [1:0]    trans_type;
    
    // Constraints
    constraint c_wait_reasonable {
        wait_cycles inside {[0:20]};
    }
    
    constraint c_mostly_ok {
        return_error dist {0 := 95, 1 := 5};  // 5% error rate
    }
    
    `uvm_object_utils_begin(ahb_slave_seq_item)
        `uvm_field_int(wait_cycles, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(return_error, UVM_DEFAULT)
        `uvm_field_int(addr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(write, UVM_DEFAULT)
        `uvm_field_int(write_data, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(read_data, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end
    
    function new(string name = "ahb_slave_seq_item");
        super.new(name);
    endfunction

endclass

`endif
