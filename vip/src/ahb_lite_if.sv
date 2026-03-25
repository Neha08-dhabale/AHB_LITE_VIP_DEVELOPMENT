`ifndef AHB_LITE_IF_SV
`define AHB_LITE_IF_SV

interface ahb_lite_if(input logic HCLK, input logic HRESETn);
    
    // AHB-Lite signals
    logic [31:0]  HADDR;
    logic [1:0]   HTRANS;
    logic         HWRITE;
    logic [2:0]   HSIZE;
    logic [2:0]   HBURST;
    logic [3:0]   HPROT;
    logic [31:0]  HWDATA;
    logic         HSEL;
    logic         HREADY;
    logic         HREADYOUT;
    logic [31:0]  HRDATA;
    logic         HRESP;
    
    // Master clocking block
    clocking master_cb @(posedge HCLK);
        default input #1step output #1step;
        output HADDR;
        output HTRANS;
        output HWRITE;
        output HSIZE;
        output HBURST;
        output HPROT;
        output HWDATA;
        output HSEL;
        input  HREADY;
        input  HREADYOUT;
        input  HRDATA;
        input  HRESP;
    endclocking
    
    // Slave clocking block
    clocking slave_cb @(posedge HCLK);
        default input #1step output #1step;
        input  HADDR;
        input  HTRANS;
        input  HWRITE;
        input  HSIZE;
        input  HBURST;
        input  HPROT;
        input  HWDATA;
        input  HSEL;
        input  HREADY;
        output HREADYOUT;
        output HRDATA;
        output HRESP;
    endclocking
    
    // Monitor clocking block
    clocking monitor_cb @(posedge HCLK);
        default input #1step;
        input HADDR;
        input HTRANS;
        input HWRITE;
        input HSIZE;
        input HBURST;
        input HPROT;
        input HWDATA;
        input HSEL;
        input HREADY;
        input HREADYOUT;
        input HRDATA;
        input HRESP;
    endclocking
    
endinterface

`endif








/*
`ifndef AHB_LITE_IF_SV
`define AHB_LITE_IF_SV

interface ahb_lite_if (
    input logic HCLK,
    input logic HRESETn
);

    // AHB-Lite signals
    logic [31:0]  HADDR;
    logic [1:0]   HTRANS;
    logic         HWRITE;
    logic [2:0]   HSIZE;
    logic [2:0]   HBURST;
    logic [3:0]   HPROT;
    logic [31:0]  HWDATA;
    logic         HSEL;
    logic         HREADY;
    logic         HREADYOUT;
    logic [31:0]  HRDATA;
    logic         HRESP;

    // Clocking block for driver
    clocking master_cb @(posedge HCLK);
        default input #1step output #0;
        output HADDR, HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HSEL;
        input  HREADY, HREADYOUT, HRDATA, HRESP;
    endclocking

    // Clocking block for monitor
    clocking monitor_cb @(posedge HCLK);
        default input #1step;
        input HADDR, HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HSEL;
        input HREADY, HREADYOUT, HRDATA, HRESP;
    endclocking

    // Modports
    modport master (clocking master_cb, input HCLK, HRESETn);
    modport monitor (clocking monitor_cb, input HCLK, HRESETn);

    // Protocol assertions
    property p_hready_stable;
        @(posedge HCLK) disable iff (!HRESETn)
        (HSEL && HTRANS[1] && !HREADY) |=> $stable(HADDR);
    endproperty

    assert property (p_hready_stable)
        else $error("HADDR changed during wait state");

endinterface : ahb_lite_if

`endif
*/



