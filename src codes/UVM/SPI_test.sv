package SPI_test_pkg;
    import uvm_pkg::*;
    import SPI_env_pkg::*;
    import SPI_config_pkg::*;
    import SPI_sequence_pkg::*;
    `include "uvm_macros.svh"

    class SPI_test extends uvm_test;
        `uvm_component_utils(SPI_test)

        SPI_config SPI_cfg;
        SPI_env env;
        SPI_reset_sequence reset_seq;
        SPI_write_address_sequence write_address_seq;
        SPI_write_data_sequence write_data_seq;
        SPI_read_address_sequence read_address_seq;
        SPI_read_data_sequence read_data_seq;
        SPI_random_sequence random_seq;

        function new(string name = "SPI_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            SPI_cfg = SPI_config::type_id::create("SPI_cfg");
            env = SPI_env::type_id::create("env", this);
            reset_seq = SPI_reset_sequence::type_id::create("reset_seq");
            write_address_seq = SPI_write_address_sequence::type_id::create("write_address_seq");
            write_data_seq = SPI_write_data_sequence::type_id::create("write_data_seq");
            read_address_seq = SPI_read_address_sequence::type_id::create("read_address_seq");
            read_data_seq = SPI_read_data_sequence::type_id::create("read_data_seq");
            random_seq = SPI_random_sequence::type_id::create("random_seq");

            if(!uvm_config_db #(virtual SPI_if)::get(this, "", "SPI_IF", SPI_cfg.SPI_vif))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the SPI from the uvm_config_db");

            uvm_config_db #(SPI_config)::set(this, "*", "CFG", SPI_cfg);
        endfunction //build_phase()

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            phase.raise_objection(this);
            
            // Main test sequence 
            // Reset sequence
            `uvm_info("run_phase", "Reset Asserted", UVM_LOW);
            reset_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Reset Deasserted", UVM_LOW);

            // Write address sequence
            `uvm_info("run_phase", "Write Address Sequence Started", UVM_LOW);
            write_address_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Write Address Sequence Ended", UVM_LOW);

            // Write data sequence
            `uvm_info("run_phase", "Write Data Sequence Started", UVM_LOW);
            write_data_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Write Data Sequence Ended", UVM_LOW);

            // Read address sequence
            `uvm_info("run_phase", "Read Address Sequence Started", UVM_LOW);
            read_address_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Read Address Sequence Ended", UVM_LOW);

            // Read data sequence
            `uvm_info("run_phase", "Read Data Sequence Started", UVM_LOW);
            read_data_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Read Data Sequence Ended", UVM_LOW);

            
            // Random sequence
            `uvm_info("run_phase", "Random Sequence Started", UVM_LOW);
            random_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Random Sequence Ended", UVM_LOW);

            phase.drop_objection(this);
        endtask //run_phase()
    endclass //SPI_test extends superClass
endpackage