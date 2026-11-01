#=============================================================
# sim.do
# run from the tb folder
# usage:  do sim.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.tdp_ram_single_clk_TB

config wave -signalnamewidth 1

add wave -color Yellow                     /tdp_ram_single_clk_TB/clk

add wave -divider "Port A"
add wave -color Cyan                       /tdp_ram_single_clk_TB/we_a
add wave -color Orange  -radix unsigned    /tdp_ram_single_clk_TB/addr_a
add wave -color Pink    -radix hex         /tdp_ram_single_clk_TB/data_a
add wave -color Green   -radix hex         /tdp_ram_single_clk_TB/q_a

add wave -divider "Port B"
add wave -color Violet                     /tdp_ram_single_clk_TB/we_b
add wave -color Gold    -radix unsigned    /tdp_ram_single_clk_TB/addr_b
add wave -color Salmon  -radix hex         /tdp_ram_single_clk_TB/data_b
add wave -color White   -radix hex         /tdp_ram_single_clk_TB/q_b

run -all
wave zoom full
