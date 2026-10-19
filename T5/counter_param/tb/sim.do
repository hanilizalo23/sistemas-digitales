#=============================================================
# sim.do
# run from the tb folder
# usage:  do sim.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.Counter_Param_Sync_TB

config wave -signalnamewidth 1

add wave -color Yellow                   /Counter_Param_Sync_TB/clk
add wave -color Cyan                     /Counter_Param_Sync_TB/rst
add wave -color Magenta                  /Counter_Param_Sync_TB/enable
add wave -color Green   -radix unsigned  /Counter_Param_Sync_TB/Q

run -all
wave zoom full
