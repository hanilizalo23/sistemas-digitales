#=============================================================
# sim.do
# run from the tb folder
# usage:  do sim.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.counter_compare_tb

run -all
