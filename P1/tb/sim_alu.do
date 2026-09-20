#=============================================================
# sim_alu.do
# run from the tb folder
# usage:  do sim_alu.do <testbench_name> <radix>
#   do sim_alu.do alu_arith_tb decimal
#   do sim_alu.do alu_logic_tb binary
#   do sim_alu.do signed_to_bcd_tb decimal
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.$1

add wave /$1/*
radix -$2

run 120ns
wave zoom full
