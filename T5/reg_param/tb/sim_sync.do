#=============================================================
# sim_sync.do
# run from the tb folder
# usage:  do sim_sync.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.Reg_Param_Sync_TB

config wave -signalnamewidth 1

add wave -color Yellow              /Reg_Param_Sync_TB/clk
add wave -color Cyan                /Reg_Param_Sync_TB/rst_n
add wave -color Magenta             /Reg_Param_Sync_TB/enable
add wave -color Orange  -radix hex  /Reg_Param_Sync_TB/D
add wave -color Green   -radix hex  /Reg_Param_Sync_TB/Q

run 1000ns
wave zoom full