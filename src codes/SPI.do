vlib work
vlog ram.v SPI.v SPI_wrapper.v SPI_if.sv SPI_config.sv SPI_seq_item.sv SPI_driver.sv \
    SPI_monitor.sv SPI_sequence.sv SPI_sequencer.sv SPI_agent.sv SPI_scoreboard.sv \
    SPI_coverage.sv SPI_env.sv SPI_test.sv SPI_top.sv
vsim -voptargs=+acc work.SPI_top -classdebug -uvmcontrol=all
add wave -r sim:/SPI_top/SPI_wrapper/*
run -all