#=============================================================
# sim.do
# run from the tb folder
# usage:  do sim.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.dual_port_rom_TB

config wave -signalnamewidth 1

add wave -color Yellow                   /dual_port_rom_TB/clk

add wave -divider "Port A"
add wave -color Orange  -radix unsigned  /dual_port_rom_TB/addr_a
add wave -color Green   -radix ascii     /dual_port_rom_TB/q_a

add wave -divider "Port B"
add wave -color Gold    -radix unsigned  /dual_port_rom_TB/addr_b
add wave -color Cyan    -radix ascii     /dual_port_rom_TB/q_b

run -all
wave zoom full
