`ifndef MASTER_AHB_IF_SV
`define MASTER_AHB_IF_SV

interface master_ahb_if(input logic HCLK, input logic HRESETn);
    
    // Master drives these (outputs)
    logic [31:0]  HADDR;
    logic [1:0]   HTRANS;
    logic         HWRITE;
    logic [2:0]   HSIZE;
    logic [2:0]   HBURST;
    logic [3:0]   HPROT;
    logic [31:0]  HWDATA;
    logic         HSEL;
    
    // Master samples these (inputs)
    logic         HREADY;
    logic         HREADYOUT;
    logic [31:0]  HRDATA;
    logic         HRESP;
    
    // Master driver clocking block
    clocking master_cb @(posedge HCLK);
        default input #1step output #1step;
        output HADDR, HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HSEL;
        input  HREADY, HREADYOUT, HRDATA, HRESP;
    endclocking
    
    // Monitor clocking block
    clocking monitor_cb @(posedge HCLK);
        default input #1step;
        input HADDR, HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HSEL;
        input HREADY, HREADYOUT, HRDATA, HRESP;
    endclocking
    
endinterface

`endif
