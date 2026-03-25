`ifndef SLAVE_AHB_IF_SV
`define SLAVE_AHB_IF_SV

interface slave_ahb_if(input logic HCLK, input logic HRESETn);
    
    // Slave samples these (inputs)
    logic [31:0]  HADDR;
    logic [1:0]   HTRANS;
    logic         HWRITE;
    logic [2:0]   HSIZE;
    logic [2:0]   HBURST;
    logic [3:0]   HPROT;
    logic [31:0]  HWDATA;
    logic         HSEL;
    logic         HREADY;
    
    // Slave drives these (outputs)
    logic         HREADYOUT;
    logic [31:0]  HRDATA;
    logic         HRESP;
    
    // Slave driver clocking block
    clocking slave_cb @(posedge HCLK);
        default input #1step output #1step;
        input  HADDR, HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HSEL, HREADY;
        output HREADYOUT, HRDATA, HRESP;
    endclocking
    
    // Monitor clocking block
    clocking monitor_cb @(posedge HCLK);
        default input #1step;
        input HADDR, HTRANS, HWRITE, HSIZE, HBURST, HPROT, HWDATA, HSEL, HREADY;
        input HREADYOUT, HRDATA, HRESP;
    endclocking
    
endinterface

`endif
