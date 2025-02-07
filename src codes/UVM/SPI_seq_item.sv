package SPI_seq_item_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class SPI_seq_item extends uvm_sequence_item;
        `uvm_object_utils(SPI_seq_item)

        // Group: Variables
        // Required items for SPI communication
        bit rst_n;
        bit MOSI;
        bit SS_n;

        // Response item from the slave
        logic MISO;

        // Data field for SPI transactions
        bit data_to_send[$];
        rand bit [9:0] full_data; // Full SPI frame

        // Static variable to enforce transitions: 00 → 01 → 10 → 11
        static bit [1:0] command_bits = 2'b00;

        constraint full_data_con {
            full_data[9:8] == command_bits;  // Enforce sequential transition
            full_data[7:0] inside {[8'h00 : 8'hFF]}; // Randomized LSBs
        }

        function new(string name = "SPI_seq_item");
            super.new(name);
        endfunction //new()

        // Group: Functions
        function string convert2string();
            string s;
            s = super.convert2string();
            return $sformatf("%s rst_n = %0d, MOSI = %0d, SS_n = %0d, MISO = %0d", s, rst_n, MOSI, SS_n, MISO);
        endfunction //convert2string()

        function string convert2string_stimulus();
            return $sformatf("rst_n = %0d, MOSI = %0d, SS_n = %0d, MISO = %0d", rst_n, MOSI, SS_n, MISO);
        endfunction //convert2string_stimulus()

        function void post_randomize();
            command_bits = command_bits + 1; // Move to next state
        endfunction
    endclass //SPI_seq_item
endpackage