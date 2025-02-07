package SPI_coverage_pkg;
    import uvm_pkg::*;
    import SPI_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class SPI_coverage extends uvm_component;
        `uvm_component_utils(SPI_coverage)

        uvm_analysis_export #(SPI_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(SPI_seq_item) cov_fifo;
        SPI_seq_item seq_item_cov;

        bit [9:0] temp_data;    // Temporary variable for 10-bit data for queue
        int bit_counter;        // Counter to track collected bits for queue

        // Covergroup for monitoring full SPI transaction fields
        covergroup cg_SPI;
            cp_SS_n: coverpoint seq_item_cov.SS_n {
                bins SS_n_low = {0};
                bins SS_n_high = {1};
            }

            cp_rst_n: coverpoint seq_item_cov.rst_n {
                bins rst_n_low = {0};
                bins rst_n_high = {1};
            }

            cp_MOSI: coverpoint seq_item_cov.MOSI {
                bins MOSI_low = {0};
                bins MOSI_high = {1};
            }
        endgroup: cg_SPI

        // Covergroup to monitor individual bits of data_to_send queue
        covergroup cg_data_queue with function sample(bit [9:0] data);
    
            cp_control_bits: coverpoint data[9:8] {
                bins write_address = {2'b00}; // Write address command
                bins write_data = {2'b01}; // Write data command
                bins read_address = {2'b10}; // Read address command
                bins read_data = {2'b11}; // Read data command
            }
        
            cp_data_bits: coverpoint data[7:0] {
                bins all_values[] = {[8'h00 : 8'hFF]}; // Covers all possible data values
            }
        
            cross cp_control_bits, cp_data_bits;
        endgroup        

        function new(string name = "SPI_coverage", uvm_component parent = null);
            super.new(name, parent);
            cg_SPI = new();
            cg_data_queue = new();
            temp_data = 10'b0;
            bit_counter = 0;
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
        
            forever begin
                cov_fifo.get(seq_item_cov);
        
                // Sample full transaction signals
                cg_SPI.sample();
                
                foreach(seq_item_cov.data_to_send[i]) begin
                    // Shift in new bit from queue
                    temp_data = {temp_data[8:0], seq_item_cov.data_to_send[i]};
                    bit_counter++;
        
                    // Sample when 10 bits have been collected
                    if (bit_counter == 10) begin
                        cg_data_queue.sample(temp_data);
                        bit_counter = 0; // Reset counter for the next frame
                    end
                end
        
                `uvm_info("SPI_coverage", $sformatf(
                    "Coverage Sampled for Full Data: %b and Queue: %p", 
                    seq_item_cov.full_data, seq_item_cov.data_to_send), UVM_HIGH);
            end
        endtask        
    endclass
endpackage