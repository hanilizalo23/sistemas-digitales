#=============================================================
# sim_system.do  -  the three patterns on the whole system
# run from the tb folder:  do sim_system.do
#=============================================================

catch {quit -sim}
vlib work
vlog ../src/*.sv
vlog *.sv
vsim -voptargs=+acc work.cache_system_TB
config wave -signalnamewidth 1

add wave -color Yellow                   /cache_system_TB/clk
add wave -divider "Generator"
add wave -color Cyan                     /cache_system_TB/start
add wave -color Cyan    -radix unsigned  /cache_system_TB/pattern_sel
add wave -color Magenta                  /cache_system_TB/UUT/generator/state
add wave -color Orange  -radix unsigned  /cache_system_TB/UUT/generator/pass
add wave -color Orange  -radix unsigned  /cache_system_TB/UUT/generator/item
add wave -color Orange  -radix hex       /cache_system_TB/UUT/req_addr
add wave -color Cyan                     /cache_system_TB/UUT/req_we
add wave -color Green                    /cache_system_TB/UUT/resp_ready
add wave -divider "Cache"
add wave -color Magenta                  /cache_system_TB/UUT/cache_core/ctrl/state
add wave -color Gold                     /cache_system_TB/mem_valid
add wave -color Gold                     /cache_system_TB/mem_we
add wave -divider "Counters"
add wave -color White   -radix unsigned  /cache_system_TB/hits
add wave -color White   -radix unsigned  /cache_system_TB/misses
add wave -color Red     -radix unsigned  /cache_system_TB/evictions
add wave -color Green                    /cache_system_TB/done

run -all
wave zoom full
