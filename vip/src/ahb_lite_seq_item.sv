`ifndef AHB_LITE_SEQ_ITEM_SV
`define AHB_LITE_SEQ_ITEM_SV

class ahb_lite_seq_item extends uvm_sequence_item;
    
    rand bit          write;
    rand bit [31:0]   addr;
    rand ahb_htrans_e trans_type;
    rand ahb_hsize_e  size;
    rand ahb_hburst_e burst;
    rand bit [3:0]    prot;
    rand bit [31:0]   data;
    
    ahb_hresp_e       resp;
    int               wait_cycles;
    
    constraint c_valid_trans {
        trans_type inside {NONSEQ, SEQ, IDLE};
    }
    
    constraint c_valid_size {
        size == SIZE_WORD;
    }
    
    constraint c_valid_burst {
        burst == SINGLE;
    }
    
    constraint c_aligned_addr {
        addr[1:0] == 2'b00;
    }
    
    `uvm_object_utils_begin(ahb_lite_seq_item)
        `uvm_field_int(write, UVM_DEFAULT)
        `uvm_field_int(addr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum(ahb_htrans_e, trans_type, UVM_DEFAULT)
        `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum(ahb_hresp_e, resp, UVM_DEFAULT)
        `uvm_field_int(wait_cycles, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "ahb_lite_seq_item");
        super.new(name);
    endfunction
    
function void make_read(bit [31:0] address);
    write      = 0;
    addr       = address;
    trans_type = NONSEQ;
    size       = SIZE_WORD;    // 3'b010 = 32-bit
    burst      = SINGLE;       // 3'b000
    prot       = 4'b0011;      // cacheable
endfunction
        
    function void make_write(bit [31:0] address, bit [31:0] write_data);
        write = 1;
        addr = address;
        data = write_data;
        trans_type = NONSEQ;
    endfunction

endclass : ahb_lite_seq_item

`endif
