#=============================================================
# sim_left.do
# run from the tb folder
# usage:  do sim_left.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.Shift_Register_L_Param_TB

config wave -signalnamewidth 1

add wave -color Yellow                 /Shift_Register_L_Param_TB/clk
add wave -color Cyan                   /Shift_Register_L_Param_TB/rst
add wave -color Magenta                /Shift_Register_L_Param_TB/enable
add wave -color Orange                 /Shift_Register_L_Param_TB/d
add wave -color Green   -radix binary  /Shift_Register_L_Param_TB/Q

run 300ns
wave zoom full
