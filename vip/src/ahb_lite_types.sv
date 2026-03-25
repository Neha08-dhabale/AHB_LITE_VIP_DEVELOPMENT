`ifndef AHB_LITE_TYPES_SV
`define AHB_LITE_TYPES_SV

typedef enum logic [1:0] {
    IDLE   = 2'b00,
    BUSY   = 2'b01,
    NONSEQ = 2'b10,
    SEQ    = 2'b11
} ahb_htrans_e;

typedef enum logic [2:0] {
    SIZE_BYTE     = 3'b000,
    SIZE_HALFWORD = 3'b001,
    SIZE_WORD     = 3'b010,
    SIZE_DWORD    = 3'b011
} ahb_hsize_e;

typedef enum logic [2:0] {
    SINGLE = 3'b000,
    INCR   = 3'b001,
    WRAP4  = 3'b010,
    INCR4  = 3'b011
} ahb_hburst_e;

typedef enum logic {
    OKAY  = 1'b0,
    ERROR = 1'b1
} ahb_hresp_e;

typedef enum {
    AHB_MASTER,
    AHB_SLAVE,
    AHB_PASSIVE
} ahb_agent_mode_e;

`endif

