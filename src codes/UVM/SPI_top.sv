import uvm_pkg::*;
import SPI_test_pkg::*;
`include "uvm_macros.svh"

module SPI_top;
    bit clk;
    always #5 clk = ~clk;
    SPI_if SPIif (clk);
    SPI_wrapper SPI_wrapper (
        clk,
        SPIif.rst_n,
        SPIif.MOSI,
        SPIif.SS_n,
        SPIif.MISO
    );

    initial begin
        uvm_config_db #(virtual SPI_if)::set(null, "uvm_test_top", "SPI_IF", SPIif);
        run_test("SPI_test");
    end
endmodule