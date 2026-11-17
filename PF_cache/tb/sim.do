#=============================================================
# sim.do  -  cache with the memory model
# run from the tb folder:  do sim.do
#=============================================================

catch {quit -sim}
vlib work
vlog ../src/*.sv
vlog *.sv
vsim -voptargs=+acc work.cache_TB
config wave -signalnamewidth 1

add wave -color Yellow                   /cache_TB/clk
add wave -divider "Request"
add wave -color Cyan                     /cache_TB/req_valid
add wave -color Cyan                     /cache_TB/req_we
add wave -color Orange  -radix hex       /cache_TB/req_addr
add wave -color Orange  -radix hex       /cache_TB/req_wdata
add wave -color Green                    /cache_TB/resp_ready
add wave -color Green   -radix hex       /cache_TB/resp_rdata
add wave -divider "Control"
add wave -color Magenta                  /cache_TB/UUT/ctrl/state
add wave -color Pink                     /cache_TB/UUT/hit
add wave -color Pink    -radix unsigned  /cache_TB/UUT/hit_way
add wave -color Pink    -radix unsigned  /cache_TB/UUT/victim_way
add wave -color Pink                     /cache_TB/UUT/victim_dirty
add wave -divider "Memory"
add wave -color Gold                     /cache_TB/mem_valid
add wave -color Gold                     /cache_TB/mem_we
add wave -color Gold    -radix hex       /cache_TB/mem_addr
add wave -color Gold                     /cache_TB/mem_ready
add wave -divider "Events"
add wave -color White                    /cache_TB/ev_hit
add wave -color White                    /cache_TB/ev_miss
add wave -color Red                      /cache_TB/ev_evict

run -all
wave zoom full
