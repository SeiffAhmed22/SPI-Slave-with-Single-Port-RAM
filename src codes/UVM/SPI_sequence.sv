package SPI_sequence_pkg;
    import uvm_pkg::*;
    import SPI_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class SPI_reset_sequence extends uvm_sequence #(SPI_seq_item);
        `uvm_object_utils(SPI_reset_sequence)

        SPI_seq_item seq_item;
        
        function new(string name = "SPI_reset_sequence");
            super.new(name);
        endfunction

        task body();
            seq_item = SPI_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            seq_item.rst_n = 0;
            seq_item.SS_n = 1;
            seq_item.MOSI = 0;
            finish_item(seq_item);
        endtask
    endclass : SPI_reset_sequence

    class SPI_write_address_sequence extends uvm_sequence #(SPI_seq_item);
        `uvm_object_utils(SPI_write_address_sequence)
    
        SPI_seq_item seq_item;
        
        function new(string name = "SPI_write_address_sequence");
            super.new(name);
        endfunction
    
        task body();
            seq_item = SPI_seq_item::type_id::create("seq_item");
    
            seq_item.full_data = {2'b00, 8'hA5}; // Full SPI frame
    
            // Ensure queue is empty before pushing new bits
            seq_item.data_to_send.delete();

            // Declare loop variable BEFORE any procedural statements
            foreach(seq_item.full_data[i]) begin
                seq_item.data_to_send.push_back(seq_item.full_data[i]); // Push each bit front
            end

            `uvm_info("SPI_write_address_sequence", $sformatf(
                "Data to send: %p, Size: %0d", seq_item.data_to_send, seq_item.data_to_send.size()), UVM_DEBUG)
    
            start_item(seq_item);
            seq_item.SS_n = 0;
            seq_item.rst_n = 1;
            finish_item(seq_item);
    
            start_item(seq_item);
            seq_item.MOSI = 0;
            finish_item(seq_item);
    
            // Use foreach properly
            foreach(seq_item.data_to_send[i]) begin
                start_item(seq_item);
                seq_item.MOSI = seq_item.data_to_send[i];
                finish_item(seq_item);
            end
    
            start_item(seq_item);
            seq_item.SS_n = 1;
            finish_item(seq_item);
        endtask
    endclass : SPI_write_address_sequence    

    class SPI_write_data_sequence extends uvm_sequence #(SPI_seq_item);
        `uvm_object_utils(SPI_write_data_sequence)
    
        SPI_seq_item seq_item;
        
        function new(string name = "SPI_write_data_sequence");
            super.new(name);
        endfunction
    
        task body();
            seq_item = SPI_seq_item::type_id::create("seq_item");
    
            seq_item.full_data = {2'b01, 8'hFF}; // Full SPI frame
    
            seq_item.data_to_send.delete(); // Ensure queue is cleared

            // Declare before use
            foreach(seq_item.full_data[i]) begin
                seq_item.data_to_send.push_back(seq_item.full_data[i]);
            end
    
            start_item(seq_item);
            seq_item.SS_n = 0;
            seq_item.rst_n = 1;
            finish_item(seq_item);
    
            start_item(seq_item);
            seq_item.MOSI = 0;
            finish_item(seq_item);
    
            foreach(seq_item.data_to_send[i]) begin
                start_item(seq_item);
                seq_item.MOSI = seq_item.data_to_send[i];
                finish_item(seq_item);
            end
    
            start_item(seq_item);
            seq_item.SS_n = 1;
            finish_item(seq_item);
        endtask
    endclass : SPI_write_data_sequence    

    class SPI_read_address_sequence extends uvm_sequence #(SPI_seq_item);
        `uvm_object_utils(SPI_read_address_sequence)
    
        SPI_seq_item seq_item;
        
        function new(string name = "SPI_read_address_sequence");
            super.new(name);
        endfunction
    
        task body();
            seq_item = SPI_seq_item::type_id::create("seq_item");
    
            seq_item.full_data = {2'b10, 8'hA5}; // Full SPI frame
    
            seq_item.data_to_send.delete();
    
            foreach(seq_item.full_data[i]) begin
                seq_item.data_to_send.push_back(seq_item.full_data[i]);
            end
    
            start_item(seq_item);
            seq_item.SS_n = 0;
            seq_item.rst_n = 1;
            finish_item(seq_item);
    
            start_item(seq_item);
            seq_item.MOSI = 1;
            finish_item(seq_item);
    
            foreach(seq_item.data_to_send[i]) begin
                start_item(seq_item);
                seq_item.MOSI = seq_item.data_to_send[i];
                finish_item(seq_item);
            end
    
            start_item(seq_item);
            seq_item.SS_n = 1;
            finish_item(seq_item);
        endtask
    endclass : SPI_read_address_sequence    

    class SPI_read_data_sequence extends uvm_sequence #(SPI_seq_item);
        `uvm_object_utils(SPI_read_data_sequence)
    
        SPI_seq_item seq_item;
        
        function new(string name = "SPI_read_data_sequence");
            super.new(name);
        endfunction
    
        task body();
            seq_item = SPI_seq_item::type_id::create("seq_item");
    
            seq_item.full_data = {2'b11, 8'hFF}; // Full SPI frame
    
            seq_item.data_to_send.delete();
    
            foreach(seq_item.full_data[i]) begin
                seq_item.data_to_send.push_back(seq_item.full_data[i]);
            end
    
            start_item(seq_item);
            seq_item.SS_n = 0;
            seq_item.rst_n = 1;
            finish_item(seq_item);
    
            start_item(seq_item);
            seq_item.MOSI = 1;
            finish_item(seq_item);
    
            foreach(seq_item.data_to_send[i]) begin
                start_item(seq_item);
                seq_item.MOSI = seq_item.data_to_send[i];
                finish_item(seq_item);
            end
    
            repeat(9) begin
                start_item(seq_item);
                seq_item.SS_n = 0;
                finish_item(seq_item);
            end
    
            start_item(seq_item);
            seq_item.SS_n = 1;
            finish_item(seq_item);
        endtask
    endclass : SPI_read_data_sequence    

    class SPI_random_sequence extends uvm_sequence #(SPI_seq_item);
        `uvm_object_utils(SPI_random_sequence)
    
        SPI_seq_item seq_item;
    
        function new(string name = "SPI_random_sequence");
            super.new(name);
        endfunction
    
        task body();
            seq_item = SPI_seq_item::type_id::create("seq_item");
    
            repeat(2000) begin
                for (int i = 0; i < 4; i++) begin  // Loop to generate 4 transactions
                    if (!seq_item.randomize()) begin
                        `uvm_fatal("SPI_random_sequence", "Randomization failed!")
                    end

                    `uvm_info("SPI_random_sequence", $sformatf("Full data: %h", seq_item.full_data), UVM_DEBUG)

                    seq_item.data_to_send.delete();
    
                    foreach(seq_item.full_data[i]) begin
                        seq_item.data_to_send.push_back(seq_item.full_data[i]);
                    end
        
                    start_item(seq_item);
                    seq_item.SS_n = 0; // Begin SPI transaction
                    seq_item.rst_n = 1;
                    finish_item(seq_item);
        
                    start_item(seq_item);
                    seq_item.MOSI = seq_item.data_to_send[0]; // Send control bit
                    finish_item(seq_item);
        
                    foreach(seq_item.data_to_send[i]) begin
                        start_item(seq_item);
                        seq_item.MOSI = seq_item.data_to_send[i];
                        finish_item(seq_item);
                    end

                    if(i == 3) begin
                        repeat(9) begin
                            start_item(seq_item);
                            seq_item.SS_n = 0;
                            finish_item(seq_item);
                        end
                    end
        
                    start_item(seq_item);
                    seq_item.SS_n = 1; // End SPI transaction
                    finish_item(seq_item);
                end
            end
        endtask
    endclass : SPI_random_sequence
endpackage