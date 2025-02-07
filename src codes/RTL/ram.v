module ram #(
    parameter MEM_DEPTH = 256, // Memory depth
    parameter ADDR_SIZE = 8 // Address size
    ) (
    input clk, // Clock
    input rst_n, // Asynchronous reset
    input [9:0] din, // Data input
    input rx_valid, // If HIGH: accept din[7:0] to save write/read address internally or write a memory word depending on din[9:8]
    output reg [7:0] dout, // Data output
    output reg tx_valid // Whenever the command is memory read, this signal is HIGH
    );
    reg [7:0] memory [MEM_DEPTH-1:0]; // Memory array
    reg [ADDR_SIZE-1:0] addr_wr; // Address register for write
    reg [ADDR_SIZE-1:0] addr_rd; // Address register for read

    // din[9:8] 
    //      00: Hold din[7:0] as Write address
    //      01: Write din[7:0] to memory[addr_wr] with write address held previously
    //      10: Hold din[7:0] as Read address
    //      11: Read memory[addr_rd] with read address held previously, tx_valid is HIGH, dout is the read data, din[7:0] is ignored

    // State machine
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            addr_wr <= 0;
            addr_rd <= 0;
            tx_valid <= 0;
            dout <= 0;
        end
        else if (rx_valid) begin
            case (din[9:8])
                2'b00: begin // Write address
                    addr_wr <= din[7:0];
                    tx_valid <= 0;
                end
                2'b01: begin // Write data
                    memory[addr_wr] <= din[7:0];
                    tx_valid <= 0;
                end
                2'b10: begin // Read address
                    addr_rd <= din[7:0] ;
                    tx_valid <= 0;
                end
                2'b11: begin // Read data
                    dout <= memory[addr_rd];
                    tx_valid <= 1;
                end
                default: begin
                    tx_valid <= 0;
                end
            endcase
        end
    end
endmodule