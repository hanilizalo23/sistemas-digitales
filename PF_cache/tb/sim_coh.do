#=============================================================
# sim_coh.do  -  two coherent caches on a shared bus
# run from the tb folder:  do sim_coh.do
#=============================================================

catch {quit -sim}
vlib work
vlog ../src/*.sv
vlog *.sv
vsim -voptargs=+acc work.coh_TB
config wave -signalnamewidth 1

add wave -color Yellow                   /coh_TB/clk
add wave -divider "CPU0"
add wave -color Cyan                     {/coh_TB/req_valid[0]}
add wave -color Cyan                     {/coh_TB/req_we[0]}
add wave -color Orange  -radix hex       {/coh_TB/req_addr[0]}
add wave -color Green                    {/coh_TB/resp_ready[0]}
add wave -color Green   -radix hex       {/coh_TB/resp_rdata[0]}
add wave -color Magenta                  /coh_TB/cpu[0]/cache/ctrl/state
add wave -divider "CPU1"
add wave -color Cyan                     {/coh_TB/req_valid[1]}
add wave -color Cyan                     {/coh_TB/req_we[1]}
add wave -color Orange  -radix hex       {/coh_TB/req_addr[1]}
add wave -color Green                    {/coh_TB/resp_ready[1]}
add wave -color Green   -radix hex       {/coh_TB/resp_rdata[1]}
add wave -color Magenta                  /coh_TB/cpu[1]/cache/ctrl/state
add wave -divider "Bus"
add wave -color Magenta                  /coh_TB/bus/state
add wave -color Pink                     /coh_TB/bus/owner
add wave -color Pink    -radix unsigned  /coh_TB/bus/cmd_q
add wave -color Pink                     /coh_TB/snoop_valid
add wave -color Pink                     /coh_TB/snoop_flush
add wave -divider "Memory"
add wave -color Gold                     /coh_TB/mem_valid
add wave -color Gold                     /coh_TB/mem_we
add wave -color Gold    -radix hex       /coh_TB/mem_addr

run -all
wave zoom full
