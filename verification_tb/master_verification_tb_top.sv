`timescale 1ns/1ps

module master_verification_tb_top;
    
    import uvm_pkg::*;
    import ahb_lite_pkg::*;
    import ahb_slave_pkg::*;
    `include "uvm_macros.svh"
    
    // Include scoreboards
    `include "scoreboards/master_protocol_checker.sv"
    `include "scoreboards/master_functional_checker.sv"
    
    // Include environment
    `include "master_verification_env.sv"
    
    // Include tests
    `include "tests/base_master_test.sv"
    `include "tests/master_write_test.sv"
    `include "tests/master_read_test.sv"
    `include "tests/master_wait_stress_test.sv"
    `include "tests/master_error_test.sv"
    `include "tests/master_mixed_test.sv"
    
    // ========================================
    // CLOCK AND RESET
    // ========================================
    logic HCLK;
    logic HRESETn;
    
    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;
    end
    
    initial begin
        HRESETn = 0;
        repeat(5) @(posedge HCLK);
        HRESETn = 1;
        `uvm_info("TB_TOP", "Reset released", UVM_LOW)
    end
    
    // ========================================
    // TWO INDEPENDENT INTERFACES 
    // ========================================
    master_ahb_if master_if(HCLK, HRESETn);
    slave_ahb_if  slave_if(HCLK, HRESETn);
    
    // ========================================
    // WIRE CONNECTIONS (Connect the two VIPs)
    // ========================================
    
    // Master- Slave (Address phase)
    assign slave_if.HADDR   = master_if.HADDR;
    assign slave_if.HTRANS  = master_if.HTRANS;
    assign slave_if.HWRITE  = master_if.HWRITE;
    assign slave_if.HSIZE   = master_if.HSIZE;
    assign slave_if.HBURST  = master_if.HBURST;
    assign slave_if.HPROT   = master_if.HPROT;
    assign slave_if.HSEL    = master_if.HSEL;
    
    // Master- Slave (Data phase)
    assign slave_if.HWDATA  = master_if.HWDATA;
    
    // Slave- Master (Response)
    assign master_if.HRDATA    = slave_if.HRDATA;
    assign master_if.HREADYOUT = slave_if.HREADYOUT;
    assign master_if.HRESP     = slave_if.HRESP;
    
    // HREADY connections
    assign slave_if.HREADY  = slave_if.HREADYOUT;
    assign master_if.HREADY = slave_if.HREADYOUT;
    
    // ========================================
    // UVM CONFIGURATION (KEY CHANGE!)
    // ========================================
    initial begin
        // Pass SEPARATE interfaces to each VIP
        uvm_config_db#(virtual master_ahb_if)::set(null, "*.master_agent*", "vif", master_if);
        uvm_config_db#(virtual slave_ahb_if)::set(null, "*.slave_agent*", "vif", slave_if);
       // uvm_config_db#(virtual master_ahb_if)::set(null, "uvm_test_top", "vif", master_if);
        run_test();
    end
    
    // Timeout
    initial begin
        #500000;
        `uvm_error("TB_TOP", "Test timeout!")
        $finish;
    end
    
    // Waveform dumping
    initial begin
        $dumpfile("master_verification.vcd");
        $dumpvars(0, master_verification_tb_top);
    end

endmodule
