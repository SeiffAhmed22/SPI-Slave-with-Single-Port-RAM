module SPI_wrapper # (
    parameter MEM_DEPTH = 256, // Memory depth
    parameter ADDR_SIZE = 8 // Address size
    ) (
    input clk, // Clock
    input rst_n, // Asynchronous reset
    input MOSI, // Master out slave in
    input SS_n, // Slave select active low
    output MISO // Master in slave out
    );

    // SPI internal signals
    wire tx_valid, rx_valid;
    wire [7:0] tx_data;
    wire [9:0] rx_data;

    SPI SPI_SLAVE(
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(SS_n),
        .tx_valid(tx_valid),
        .MOSI(MOSI),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .MISO(MISO),
        .rx_valid(rx_valid)
    );

    ram #(
        .MEM_DEPTH(MEM_DEPTH),
        .ADDR_SIZE(ADDR_SIZE)
    ) RAM(
        .clk(clk),
        .rst_n(rst_n),
        .din(rx_data),
        .rx_valid(rx_valid),
        .dout(tx_data),
        .tx_valid(tx_valid)
    );
endmodule