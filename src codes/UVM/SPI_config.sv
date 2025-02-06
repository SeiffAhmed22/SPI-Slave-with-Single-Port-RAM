package SPI_config_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class SPI_config extends uvm_object;
        `uvm_object_utils(SPI_config)

        virtual SPI_if SPI_vif;

        function new(string name = "SPI_config");
            super.new(name);
        endfunction
    endclass
endpackage