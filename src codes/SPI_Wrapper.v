module SPI_wrapper (
    input clk, rst_n, MOSI, SS_n,
    output MISO
    );
    wire tx_valid, rx_valid;
    wire [7:0] tx_data;
    wire [9:0] rx_data;

    SPI SPI_SLAVE(
        .clk(clk), .rst_n(rst_n), .SS_n(SS_n),
        .tx_valid(tx_valid), .MOSI(MOSI),
        .tx_data(tx_data), .rx_data(rx_data),
        .MISO(MISO), .rx_valid(rx_valid)
    );

    ram RAM(
        .clk(clk), .rstn(rst_n), .din(rx_data),
        .rx_valid(rx_valid), .dout(tx_data),
        .tx_valid(tx_valid)
    );
endmodule