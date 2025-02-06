package SPI_scoreboard_pkg;
    import uvm_pkg::*;
    import SPI_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class SPI_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(SPI_scoreboard)

        // Analysis Port
        uvm_analysis_export #(SPI_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(SPI_seq_item) sb_fifo;
        SPI_seq_item seq_item_sb;

        // Internal Variables
        bit [7:0] ram_memory [256]; // Simulated RAM storage
        bit [7:0] current_address; // Holds the address for read/write
        bit [9:0] received_data;   // Stores received serial data
        int bit_count;             // Tracks received bits
        bit active_transaction;    // Tracks active SPI transactions

        function new(string name = "SPI_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
            active_transaction = 0;
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);

                // Start SPI transaction when SS_n = 0
                if (!seq_item_sb.SS_n) begin
                    active_transaction = 1; 
                    received_data = {received_data[8:0], seq_item_sb.MOSI}; // Shift data in
                    bit_count++;
                end 
                // Process transaction after full 10-bit frame is received
                else if (active_transaction) begin
                    active_transaction = 0; 

                    if (bit_count == 10) begin
                        ref_model(received_data);
                    end
                    bit_count = 0;
                end
            end
        endtask

        // **Reference Model for Expected SPI Behavior**
        task ref_model(bit [9:0] received);
            case (received[9:8])
                2'b00: begin // Write Address
                    current_address = received[7:0]; // Store write address
                    `uvm_info("SPI_scoreboard", $sformatf(
                        "Address Set: %h", current_address), UVM_MEDIUM)
                end

                2'b01: begin // Write Data
                    ram_memory[current_address] = received[7:0]; // Store data at address
                    `uvm_info("SPI_scoreboard", $sformatf(
                        "Data Written: %h at Address: %h", received[7:0], current_address), UVM_MEDIUM)
                end

                2'b10: begin // Read Address
                    current_address = received[7:0]; // Store read address
                    `uvm_info("SPI_scoreboard", $sformatf(
                        "Read Address Set: %h", current_address), UVM_MEDIUM)
                end

                2'b11: begin // Read Data
                    if (ram_memory[current_address] !== received[7:0]) begin
                        `uvm_error("SPI_scoreboard", $sformatf(
                            "Data Mismatch! Read: %h, Expected: %h at Address: %h", 
                            received[7:0], ram_memory[current_address], current_address))
                    end
                    else begin
                        `uvm_info("SPI_scoreboard", $sformatf(
                            "Data Read Matches! Read: %h, Expected: %h at Address: %h", 
                            received[7:0], ram_memory[current_address], current_address), UVM_HIGH)
                    end
                end
            endcase
        endtask
    endclass
endpackage