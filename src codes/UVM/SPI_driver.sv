package SPI_driver_pkg;
    import uvm_pkg::*;
    import SPI_seq_item_pkg::*;
    import SPI_config_pkg::*;
    `include "uvm_macros.svh"

    class SPI_driver extends uvm_driver #(SPI_seq_item);
        `uvm_component_utils(SPI_driver)

        virtual SPI_if SPI_vif;
        SPI_seq_item seq_item;

        function new(string name = "SPI_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                seq_item = SPI_seq_item::type_id::create("seq_item");
                seq_item_port.get_next_item(seq_item);
                SPI_vif.rst_n = seq_item.rst_n;
                SPI_vif.MOSI = seq_item.MOSI;
                SPI_vif.SS_n = seq_item.SS_n;
                @(negedge SPI_vif.clk);
                seq_item_port.item_done();
                `uvm_info("run_phase", seq_item.convert2string_stimulus(), UVM_HIGH)
            end
        endtask //run_phase()
    endclass //SPI_driver
endpackage