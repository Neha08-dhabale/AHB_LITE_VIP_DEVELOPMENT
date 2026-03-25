`timescale 1ns/1ps
`default_nettype none

module flash_model #(
    parameter MEM_SIZE  = 65536,
    parameter INIT_FILE = ""
)(
    input  wire       sck,
    input  wire       ce_n,
    input  wire [3:0] dout,
    output reg  [3:0] din,
    input  wire [3:0] douten
);

    // Memory
    reg [7:0] memory [0:MEM_SIZE-1];
    integer idx;

initial begin
    for (idx = 0; idx < MEM_SIZE; idx = idx + 1)
        memory[idx] = 8'hAA;   // default

    // Cache line 1: 0x1000â0x101F (32 bytes = 8 words)
    memory[16'h1000] = 8'h11; memory[16'h1001] = 8'h22;
    memory[16'h1002] = 8'h33; memory[16'h1003] = 8'h44;  // word 0 = 0x11223344

    memory[16'h1004] = 8'hAA; memory[16'h1005] = 8'hBB;
    memory[16'h1006] = 8'hCC; memory[16'h1007] = 8'hDD;  // word 1 = 0xAABBCCDD

    memory[16'h1008] = 8'hDE; memory[16'h1009] = 8'hAD;
    memory[16'h100A] = 8'hBE; memory[16'h100B] = 8'hEF;  // word 2 = 0xDEADBEEF

    memory[16'h100C] = 8'hCA; memory[16'h100D] = 8'hFE;
    memory[16'h100E] = 8'hBA; memory[16'h100F] = 8'hBE;  // word 3 = 0xCAFEBABE

    // Cache line 2: 0x1020â0x103F (8 words)
    memory[16'h1020] = 8'h55; memory[16'h1021] = 8'h66;
    memory[16'h1022] = 8'h77; memory[16'h1023] = 8'h88;  // word 8 = 0x55667788

    // fill rest of line 2 with distinct pattern
    for (idx = 16'h1024; idx < 16'h1040; idx = idx + 1)
        memory[idx] = 8'hBB;

    // 0x3000 for write test
    memory[16'h3000] = 8'hDE; memory[16'h3001] = 8'hAD;
    memory[16'h3002] = 8'hBE; memory[16'h3003] = 8'hEF;
end


/*
    initial begin
        for (idx = 0; idx < MEM_SIZE; idx = idx + 1)
            memory[idx] = 8'hAA;

        memory[16'h3000] = 8'hDE;
        memory[16'h3001] = 8'hAD;
        memory[16'h3002] = 8'hBE;
        memory[16'h3003] = 8'hEF;

        if (INIT_FILE != "")
            $readmemh(INIT_FILE, memory);

        din = 4'hz;
        $display("[FLASH] Initialized. MEM_SIZE=%0d", MEM_SIZE);
    end
*/

    // FSM state encoding
    localparam ST_IDLE  = 3'd0,
               ST_CMD   = 3'd1,
               ST_ADDR  = 3'd2,
               ST_MODE  = 3'd3,
               ST_DUMMY = 3'd4,
               ST_DATA  = 3'd5;

    reg [2:0]  state;
    reg [7:0]  cmd_shift;
    reg [23:0] addr_shift;
    reg [7:0]  mode_shift;
    reg [7:0]  bit_cnt;
    reg [23:0] read_addr;
    reg [7:0]  out_byte;
    reg        hi_nibble;
    reg        first_transaction;

    initial begin
        state             = ST_IDLE;
        cmd_shift         = 0;
        addr_shift        = 0;
        mode_shift        = 0;
        bit_cnt           = 0;
        read_addr         = 0;
        out_byte          = 0;
        hi_nibble         = 1;
        first_transaction = 1;
    end

    // CE deassert â reset FSM
    always @(posedge ce_n) begin
        if (state == ST_DATA) begin
            first_transaction <= 1'b0;
            $display("[FLASH] Transaction complete, continuous mode enabled at %0t", $time);
        end
        state   <= ST_IDLE;
        bit_cnt <= 0;
        din     <= 4'hz;
    end

    // SCK rising â receive/process data
    always @(posedge sck) begin
        if (!ce_n) begin
            case (state)

                ST_IDLE: begin
                    bit_cnt <= 8'd1;
                    if (first_transaction) begin
                        cmd_shift <= {7'b0, dout[0]};
                        state     <= ST_CMD;
                    end else begin
                        // Continuous mode â DUT skips command, sends address directly
                        addr_shift <= {20'b0, dout};
                        state      <= ST_ADDR;
                        $display("[FLASH] Continuous: addr phase direct at %0t", $time);
                    end
                end

                ST_CMD: begin
                    cmd_shift <= {cmd_shift[6:0], dout[0]};
                    bit_cnt   <= bit_cnt + 1;
                    if (bit_cnt == 7) begin
                        case ({cmd_shift[6:0], dout[0]})
                            8'hEB: begin
                                bit_cnt <= 0;
                                state   <= ST_ADDR;
                                $display("[FLASH] CMD=0xEB (Quad Read) at %0t", $time);
                            end
                            8'h66: begin
                                bit_cnt <= 0;
                                state   <= ST_IDLE;
                                $display("[FLASH] CMD=0x66 (Reset Enable) at %0t", $time);
                            end
                            8'h99: begin
                                bit_cnt <= 0;
                                state   <= ST_IDLE;
                                $display("[FLASH] CMD=0x99 (Reset) at %0t", $time);
                            end
                            default: begin
                                $display("[FLASH] Ignoring unknown CMD=0x%02h at %0t",
                                         {cmd_shift[6:0], dout[0]}, $time);
                                bit_cnt <= 0;
                                state   <= ST_IDLE;
                            end
                        endcase
                    end
                end

                ST_ADDR: begin
                    addr_shift <= {addr_shift[19:0], dout};
                    bit_cnt    <= bit_cnt + 1;
                    if (bit_cnt == 5) begin
                        read_addr <= {addr_shift[19:0], dout};
                        bit_cnt   <= 0;
                        state     <= ST_MODE;
                        $display("[FLASH] ADDR=0x%06h at %0t",
                                 {addr_shift[19:0], dout}, $time);
                    end
                end

                ST_MODE: begin
                    mode_shift <= {mode_shift[3:0], dout};
                    bit_cnt    <= bit_cnt + 1;
                    if (bit_cnt == 1) begin
                        bit_cnt <= 0;
                        state   <= ST_DUMMY;
                    end
                end

                ST_DUMMY: begin
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 3) begin
                        bit_cnt   <= 0;
                        out_byte  <= memory[read_addr];
                        hi_nibble <= 1;
                        state     <= ST_DATA;
                        $display("[FLASH] Data phase start, addr=0x%06h at %0t",
                                 read_addr, $time);
                    end
                end

                ST_DATA: begin
                    // output handled on negedge below
                end

            endcase
        end
    end

    // SCK falling â drive output data to controller
    always @(negedge sck) begin
        if (!ce_n && state == ST_DATA) begin
            if (hi_nibble) begin
                din       <= out_byte[7:4];
                hi_nibble <= 0;
            end else begin
                din       <= out_byte[3:0];
                hi_nibble <= 1;
                read_addr <= read_addr + 1;
                out_byte  <= memory[read_addr + 1];
            end
        end else begin
            din <= 4'hz;
        end
    end

    // Activity logging
    always @(negedge ce_n)
        $display("[FLASH] Transaction started at time %0t", $time);

endmodule
/*
`timescale 1ns/1ps

module flash_model (
    input  wire       sck,
    input  wire       ce_n,
    input  wire [3:0] dout,  // From controller
    output reg  [3:0] din,   // To controller
    input  wire [3:0] douten
);

    // Simple memory array
    reg [7:0] memory [0:65535];  // 64KB
    
    // Initialize with test pattern
    initial begin
        for (int i = 0; i < 65536; i++) begin
            memory[i] = i[7:0];  // Simple pattern
        end
        
        // Put some recognizable data at specific addresses
        memory[16'h1000] = 8'hAA;
        memory[16'h1001] = 8'hBB;
        memory[16'h1002] = 8'hCC;
        memory[16'h1003] = 8'hDD;
        
        memory[16'h1004] = 8'h11;
        memory[16'h1005] = 8'h22;
        memory[16'h1006] = 8'h33;
        memory[16'h1007] = 8'h44;
    end
    
    // Simple response - just return data
    // In real flash, you'd decode commands, addresses, etc.
    always @(posedge sck or posedge ce_n) begin
        if (!ce_n) begin
            // Return some data (simplified)
            din <= 4'hA;  // Dummy data for now
        end else begin
            din <= 4'h0;
        end
    end
    
    // Display activity
    always @(negedge ce_n) begin
        $display("[FLASH] Transaction started at time %0t", $time);
    end

endmodule

*/
