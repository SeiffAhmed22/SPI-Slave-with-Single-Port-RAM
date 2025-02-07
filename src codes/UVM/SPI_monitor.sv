package SPI_monitor_pkg;
    import uvm_pkg::*;
    import SPI_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class SPI_monitor extends uvm_monitor;
        `uvm_component_utils(SPI_monitor)

        virtual SPI_if SPI_vif;
        SPI_seq_item seq_item;
        uvm_analysis_port #(SPI_seq_item) mon_ap;

        function new(string name = "SPI_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap", this);
        endfunction //build_phase()

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                seq_item = SPI_seq_item::type_id::create("seq_item");
                @(negedge SPI_vif.clk);
                seq_item.SS_n = SPI_vif.SS_n;
                seq_item.rst_n = SPI_vif.rst_n;
                seq_item.MISO = SPI_vif.MISO;
                seq_item.MOSI = SPI_vif.MOSI;
                seq_item.data_to_send.push_back(SPI_vif.MOSI);
                mon_ap.write(seq_item);
                `uvm_info("run_phase", seq_item.convert2string(), UVM_HIGH)
            end
        endtask //run_phase()
    endclass //SPI_monitor
endpackage