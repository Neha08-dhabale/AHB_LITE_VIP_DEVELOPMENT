`timescale 1ns/1ps

module tb_top;
    
    import uvm_pkg::*;
    import ahb_lite_pkg::*;
    `include "uvm_macros.svh"
    
    // Include test files
    `include "tb_env.sv"
    `include "tb_test.sv"
    
    // Clock and reset
    logic HCLK;
    logic HRESETn;
    
    // QSPI flash signals
    wire        sck;
    wire        ce_n;
    wire [3:0]  din;
    wire [3:0]  dout;
    wire [3:0]  douten;
    
    // Instantiate AHB-Lite interface
    ahb_lite_if vif(HCLK, HRESETn);
    
    // Clock generation (100 MHz)
    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;
    end
    
    // Reset generation
    initial begin
        HRESETn = 0;
        repeat(20) @(posedge HCLK);
        HRESETn = 1;
        `uvm_info("TB_TOP", "Reset released", UVM_LOW)
    end
    
    // Tie HREADY (no other masters)
    assign vif.HREADY = vif.HREADYOUT;
    
    // DUT: QSPI XIP Controller
    EF_QSPI_XIP_CTRL_AHBL #(
        .NUM_LINES(16),
        .LINE_SIZE(32),
        .RESET_CYCLES(10)  // Short for simulation
    ) dut (
        .HCLK(vif.HCLK),
        .HRESETn(vif.HRESETn),
        .HSEL(vif.HSEL),
        .HADDR(vif.HADDR),
        .HTRANS(vif.HTRANS),
        .HWRITE(vif.HWRITE),
        .HREADY(vif.HREADY),
        .HREADYOUT(vif.HREADYOUT),
        .HRDATA(vif.HRDATA),
        .sck(sck),
        .ce_n(ce_n),
        .din(din),
        .dout(dout),
        .douten(douten)
    );

   /* 
    // Flash model
    flash_model flash (
        .sck(sck),
        .ce_n(ce_n),
        .dout(dout),
        .din(din),
        .douten(douten)
    );
*/

flash_model #(
        .MEM_SIZE  (65536),     // 64KB â same as before
        .INIT_FILE ("")         // leave empty to use built-in pattern
                                // or: .INIT_FILE("flash_init.hex")
    ) flash (
        .sck    (sck),
        .ce_n   (ce_n),
        .dout   (dout),         // controller â flash (our input)
        .din    (din),          // flash â controller (our output)
        .douten (douten)
    );
    
    // UVM configuration
    initial begin
        // Set interface in config DB
        uvm_config_db#(virtual ahb_lite_if)::set(null, "*", "vif", vif);
        
        // Run test
        run_test();
    end
    
    // Timeout watchdog
    initial begin
        #100000;
        `uvm_error("TB_TOP", "Test timeout!")
        $finish;
    end
    
    // Waveform dumping
initial begin
    $dumpfile("waves.vcd");    
    $dumpvars(0, tb_top);
end
    
endmodule
