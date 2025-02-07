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
        bit [7:0] current_write_address;  // Holds the address for write
        bit [7:0] current_read_address;   // Holds the address for read
        bit MOSI_queue [$];    // Queue for received SPI bits
        bit MISO_queue [$];    // Queue for captured MISO bits (slave response)
        bit [9:0] received_data;    // Holds received data
        int bit_count;              // Tracks received bits (total)
        int frame_bit_count;        // Tracks bits within the current frame
        bit active_transaction;     // Tracks active SPI transactions
        bit shift_enable;           // Enables shifting after 2 clock cycles

        // Error Tracking
        int error_count;
        int correct_count;

        function new(string name = "SPI_scoreboard", uvm_component parent = null);
            super.new(name, parent);
            error_count = 0;
            correct_count = 0;
            active_transaction = 0;
            shift_enable = 0;
            frame_bit_count = 0;
            received_data = 0;
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);

                `uvm_info("SPI_scoreboard", $sformatf(
                    "Received: SS_n=%b, MOSI=%b, MISO=%b, bit_count=%0d, frame_bit_count=%0d, MOSI Queue Size=%0d, MISO Queue Size=%0d", 
                    seq_item_sb.SS_n, seq_item_sb.MOSI, seq_item_sb.MISO, bit_count, frame_bit_count, MOSI_queue.size(), MISO_queue.size()), UVM_DEBUG)

                if (!seq_item_sb.SS_n) begin
                    if (bit_count == 0) begin
                        MOSI_queue.delete();
                        MISO_queue.delete();
                        frame_bit_count = 0;
                        shift_enable = 0;
                        active_transaction = 1;
                        `uvm_info("SPI_scoreboard", "Transaction Start Detected", UVM_DEBUG)
                    end

                    bit_count++;

                    if (bit_count >= 3 && bit_count <= 12) begin
                        shift_enable = 1;
                    end else if (bit_count > 12) begin
                        shift_enable = 0; // Prevent overshifting
                        MISO_queue.push_back(seq_item_sb.MISO); // Capture MISO data
                    end

                    if (shift_enable) begin
                        MOSI_queue.push_back(seq_item_sb.MOSI);
                        frame_bit_count++;
                        `uvm_info("SPI_scoreboard", $sformatf(
                            "Shifting: MOSI Queue=%p, MISO Queue=%p, frame_bit_count=%0d", 
                            MOSI_queue, MISO_queue, frame_bit_count), UVM_DEBUG)
                    end
                end 
                else if (active_transaction) begin
                    active_transaction = 0; 
                    shift_enable = 0;  

                    foreach (MOSI_queue[i]) begin
                        received_data = {received_data[8:0], MOSI_queue[i]};
                    end

                    `uvm_info("SPI_scoreboard", $sformatf(
                        "Transaction Complete: Type=%b | Frame Bits=%d", 
                        received_data[9:8], frame_bit_count), UVM_DEBUG)

                    if (frame_bit_count == 10) begin
                        `uvm_info("SPI_scoreboard", "Calling ref_model()", UVM_DEBUG)
                        ref_model(received_data);
                    end 
                    else begin
                        `uvm_error("SPI_scoreboard", "Incorrect frame size detected!")
                    end

                    bit_count = 0;
                end
            end
        endtask

        // Reference Model for Expected SPI Behavior
        task ref_model(bit [9:0] received_data);
            `uvm_info("SPI_scoreboard", $sformatf("Processing in ref_model: %b", received_data), UVM_DEBUG)

            case (received_data[9:8])
                2'b00: begin // Write Address
                    current_write_address = received_data[7:0]; // Store write address
                    `uvm_info("SPI_scoreboard", $sformatf(
                        "Address Set: %h", current_write_address), UVM_DEBUG)
                end

                2'b01: begin // Write Data
                    ram_memory[current_write_address] = received_data[7:0]; // Store data at address
                    `uvm_info("SPI_scoreboard", $sformatf(
                        "Data Written: %h at Address: %h", received_data[7:0], current_write_address), UVM_DEBUG)
                end

                2'b10: begin // Read Address
                    current_read_address = received_data[7:0]; // Store read address
                    `uvm_info("SPI_scoreboard", $sformatf(
                        "Read Address Set: %h", current_read_address), UVM_DEBUG)
                end

                2'b11: begin // Read Data
                    bit [7:0] expected_data = ram_memory[current_read_address]; // Get stored data
                    bit [7:0] received_miso_data;

                    foreach (MISO_queue[i]) begin
                        received_miso_data = {received_miso_data[6:0], MISO_queue[i]};
                    end

                    `uvm_info("SPI_scoreboard", $sformatf(
                        "Read Command Received. Expected Data from RAM: %h at Address: %h, Received MISO: %h", 
                        expected_data, current_read_address, received_miso_data), UVM_DEBUG)

                    // Compare MISO output (actual data sent by SPI slave)
                    if (received_miso_data !== expected_data) begin
                        error_count++; 
                        `uvm_error("SPI_scoreboard", $sformatf(
                            "MISO Data Mismatch! Sent: %h, Expected: %h at Address: %h", 
                            received_miso_data, expected_data, current_read_address))
                    end
                    else begin
                        correct_count++; 
                        `uvm_info("SPI_scoreboard", $sformatf(
                            "MISO Data Matches! Sent: %h, Expected: %h at Address: %h", 
                            received_miso_data, expected_data, current_read_address), UVM_DEBUG)
                    end
                end
            endcase
        endtask

        // Report Phase to Display Summary
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("SPI_scoreboard", 
                $sformatf("SPI Scoreboard Summary: \nCorrect Transactions: %0d \nErrors: %0d", 
                correct_count, error_count), UVM_NONE)
        endfunction
    endclass
endpackage