#=============================================================
# sim.do
# run from the tb folder
# usage:  do sim.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.Counter_02Limit_ovf_TB

config wave -signalnamewidth 1

add wave -color Yellow                   /Counter_02Limit_ovf_TB/clk
add wave -color Cyan                     /Counter_02Limit_ovf_TB/rst
add wave -color Magenta                  /Counter_02Limit_ovf_TB/enable
add wave -color Green   -radix unsigned  /Counter_02Limit_ovf_TB/Q
add wave -color Orange                   /Counter_02Limit_ovf_TB/overflow

run 400ns
wave zoom full
