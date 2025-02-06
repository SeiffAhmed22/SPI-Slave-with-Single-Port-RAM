package SPI_agent_pkg;
    import uvm_pkg::*;
    import SPI_sequencer_pkg::*;
    import SPI_config_pkg::*;
    import SPI_driver_pkg::*;
    import SPI_monitor_pkg::*;
    import SPI_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class SPI_agent extends uvm_agent;
        `uvm_component_utils(SPI_agent)

        SPI_config SPI_cfg;
        SPI_sequencer sqr;
        SPI_driver drv;
        SPI_monitor mon;
        uvm_analysis_port #(SPI_seq_item) agt_ap;

        function new(string name = "SPI_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(SPI_config) :: get(this, "", "CFG", SPI_cfg))
                `uvm_fatal("build_phase" , "Unable to get configuration object")

            //create the driver, sequencer and monitor
            sqr = SPI_sequencer::type_id::create("sqr",this);
            drv = SPI_driver::type_id::create("drv",this);
            mon = SPI_monitor::type_id::create("mon", this);
            agt_ap = new("agt_ap", this);
        endfunction //build_phase()

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            //connect the vif of the driver and monitor
            drv.SPI_vif = SPI_cfg.SPI_vif;
            mon.SPI_vif = SPI_cfg.SPI_vif;

            //connect the ports for the sqr and driver
            drv.seq_item_port.connect(sqr.seq_item_export);

            //connect the analysis port of the monitor and agent
            mon.mon_ap.connect(agt_ap);
        endfunction //connect_phase()


        // Debugging
        // function void connect_phase(uvm_phase phase);
        //     super.connect_phase(phase);
        
        //     if (drv == null || sqr == null)
        //         `uvm_fatal("connect_phase", "Driver or Sequencer is NULL")
        
        //     if (mon == null)
        //         `uvm_fatal("connect_phase", "Monitor is NULL")
        
        //     if (agt_ap == null)
        //         `uvm_fatal("connect_phase", "agt_ap is NULL")
        
        //     `uvm_info("connect_phase", "Starting port connections...", UVM_MEDIUM)
        
        //     drv.SPI_vif = SPI_cfg.SPI_vif;
        //     mon.SPI_vif = SPI_cfg.SPI_vif;

        //     if (drv.seq_item_port == null)
        //         `uvm_fatal("connect_phase", "drv.seq_item_port is NULL")
        
        //     if (sqr.seq_item_export == null)
        //         `uvm_fatal("connect_phase", "sqr.seq_item_export is NULL")
        
        //     drv.seq_item_port.connect(sqr.seq_item_export);
        //     `uvm_info("connect_phase", "Connected drv.seq_item_port to sqr.seq_item_export", UVM_MEDIUM)
        
        //     if (mon.mon_ap == null)
        //         `uvm_fatal("connect_phase", "mon.mon_ap is NULL")
        
        //     if (agt_ap == null)
        //         `uvm_fatal("connect_phase", "agt_ap is NULL")
        
        //     mon.mon_ap.connect(agt_ap);
        //     `uvm_info("connect_phase", "Connected mon.mon_ap to agt_ap", UVM_MEDIUM)
        // endfunction        
    endclass
endpackage