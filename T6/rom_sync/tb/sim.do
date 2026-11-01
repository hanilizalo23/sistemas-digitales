#=============================================================
# sim.do
# run from the tb folder
# usage:  do sim.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.rom_sync_TB

config wave -signalnamewidth 1

add wave -color Yellow                   /rom_sync_TB/clk
add wave -color Orange  -radix unsigned  /rom_sync_TB/address
add wave -color Green   -radix ascii     /rom_sync_TB/q_case
add wave -color Cyan    -radix ascii     /rom_sync_TB/q_array

run -all
wave zoom range 0ns 1000ns
