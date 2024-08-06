vlib work 

vlog SPI.v RAM.v SPI_Wrapper.v tb_SPI_Wrapper.v 

vsim -voptargs=+acc work.SPI_Wrapper_tb

add wave *

run
run
run
run
run
run
run