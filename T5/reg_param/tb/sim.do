#=============================================================
# sim.do
# run from the tb folder
# usage:  do sim.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.Reg_Param_TB

add wave -color Yellow              /Reg_Param_TB/clk
add wave -color Cyan                /Reg_Param_TB/rst
add wave -color Magenta             /Reg_Param_TB/enable
add wave -color Orange  -radix hex  /Reg_Param_TB/D
add wave -color Green   -radix hex  /Reg_Param_TB/Q

run 1000ns
wave zoom full