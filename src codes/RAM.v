module ram #(
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input [9:0] din,
    input clk,
    input rstn,
    input rx_valid,
    output reg [7:0] dout,
    output reg tx_valid
);

// Memory array
reg [7:0] memory [MEM_DEPTH-1:0];

reg [ADDR_SIZE-1:0] addr;

always @(posedge clk) begin
    if (!rstn) begin
        addr <= 0;
        tx_valid <= 0;
    end
    else if (rx_valid) begin
        case (din[9:8])
            2'b00: begin // Write address
                addr <= din[7:0];
                tx_valid <= 0;
            end
            2'b01: begin // Write data
                memory[addr] <= din[7:0];
                tx_valid <= 0;
            end
            2'b10: begin // Read address
                 addr <= din[7:0] ;
                 tx_valid <= 0;
            end
            2'b11: begin // Read data
                dout <= memory[addr];
                tx_valid <= 1;
            end
            default: begin
                addr <= addr;
                tx_valid <= tx_valid;
            end
        endcase
    end

end

endmodule