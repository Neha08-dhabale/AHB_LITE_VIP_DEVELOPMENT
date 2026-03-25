`ifndef AHB_SLAVE_MEMORY_SV
`define AHB_SLAVE_MEMORY_SV

class ahb_slave_memory extends uvm_object;
    
    `uvm_object_utils(ahb_slave_memory)
    
    // Sparse memory (associative array)
    bit [31:0] mem [bit [31:0]];
    
    // Configuration
    bit [31:0] default_read_data = 32'hDEADBEEF;
    bit log_accesses = 1;
    
    function new(string name = "ahb_slave_memory");
        super.new(name);
    endfunction
    
    // Write to memory
    virtual function void write(bit [31:0] addr, bit [31:0] data);
        mem[addr] = data;
        if (log_accesses)
            `uvm_info("SLAVE_MEM", $sformatf("WRITE [0x%08h] = 0x%08h", addr, data), UVM_HIGH)
    endfunction
    
    // Read from memory
    virtual function bit [31:0] read(bit [31:0] addr);
        bit [31:0] data;
        
        if (mem.exists(addr)) begin
            data = mem[addr];
        end else begin
            data = default_read_data;
        end
        
        if (log_accesses)
            `uvm_info("SLAVE_MEM", $sformatf("READ  [0x%08h] = 0x%08h %s", 
                      addr, data, mem.exists(addr) ? "" : "(default)"), UVM_HIGH)
        
        return data;
    endfunction
    
    // Initialize with pattern
    virtual function void load_pattern(bit [31:0] start_addr, int num_words, bit [31:0] base_value);
        for (int i = 0; i < num_words; i++) begin
            mem[start_addr + (i*4)] = base_value + i;
        end
        `uvm_info("SLAVE_MEM", $sformatf("Loaded %0d words from 0x%08h", num_words, start_addr), UVM_MEDIUM)
    endfunction
    
    // Clear all memory
    virtual function void clear();
        mem.delete();
        `uvm_info("SLAVE_MEM", "Memory cleared", UVM_MEDIUM)
    endfunction
    
    // Get memory statistics
    virtual function void print_stats();
        `uvm_info("SLAVE_MEM", $sformatf("Memory contains %0d entries", mem.size()), UVM_LOW)
    endfunction

endclass

`endif
