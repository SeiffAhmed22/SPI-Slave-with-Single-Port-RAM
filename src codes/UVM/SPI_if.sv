interface SPI_if (
    input bit clk
    );
    parameter MEM_DEPTH = 256; // Memory depth
    parameter ADDR_SIZE = 8; // Address size
    logic rst_n; // Asynchronous reset
    logic SS_n; // Slave Select (active low)
    logic MOSI; // Master Out Slave In
    logic MISO; // Master In Slave Out
    logic tx_valid; // Transmit valid
    logic rx_valid; // Receive valid
    logic [7:0] tx_data; // Transmit data
    logic [9:0] rx_data; // Receive data

    modport SPI (
        input clk, rst_n, SS_n, tx_valid, MOSI, tx_data,
        output rx_data, MISO, rx_valid
    );

    modport RAM (
        input clk, rst_n, rx_data, rx_valid,
        output tx_data, tx_valid
    );

    modport SPI_WRAPPER (
        input clk, rst_n, MOSI, SS_n,
        output MISO
    );
endinterface