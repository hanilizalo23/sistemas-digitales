#=============================================================
# sim.do
# run from the tb folder
# usage:  do sim.do
#=============================================================

catch {quit -sim}

vlib work

vlog ../src/*.v
vlog *.v

vsim -voptargs=+acc work.debouncer_TB

config wave -signalnamewidth 1

add wave -color Yellow                   /debouncer_TB/clk
add wave -color Cyan                     /debouncer_TB/reset_n
add wave -color Orange                   /debouncer_TB/button_in
add wave -color Pink                     /debouncer_TB/UUT/q1
add wave -color Violet                   /debouncer_TB/UUT/q2
add wave -color Magenta                  /debouncer_TB/UUT/changed
add wave -color White   -radix unsigned  /debouncer_TB/UUT/count
add wave -color Green                    /debouncer_TB/button_out

run -all
wave zoom full
