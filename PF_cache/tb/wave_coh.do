onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /coh_TB/clk
add wave -noupdate -divider CPU0
add wave -noupdate -color Cyan {/coh_TB/req_valid[0]}
add wave -noupdate -color Cyan {/coh_TB/req_we[0]}
add wave -noupdate -color Orange -radix hexadecimal {/coh_TB/req_addr[0]}
add wave -noupdate -color Green {/coh_TB/resp_ready[0]}
add wave -noupdate -color Green -radix hexadecimal {/coh_TB/resp_rdata[0]}
add wave -noupdate -color Magenta {/coh_TB/cpu[0]/cache/ctrl/state}
add wave -noupdate -divider CPU1
add wave -noupdate -color Cyan {/coh_TB/req_valid[1]}
add wave -noupdate -color Cyan {/coh_TB/req_we[1]}
add wave -noupdate -color Orange -radix hexadecimal {/coh_TB/req_addr[1]}
add wave -noupdate -color Green {/coh_TB/resp_ready[1]}
add wave -noupdate -color Green -radix hexadecimal {/coh_TB/resp_rdata[1]}
add wave -noupdate -color Magenta {/coh_TB/cpu[1]/cache/ctrl/state}
add wave -noupdate -divider Bus
add wave -noupdate -color Magenta /coh_TB/bus/state
add wave -noupdate -color Pink /coh_TB/bus/owner
add wave -noupdate -color Pink -radix unsigned /coh_TB/bus/cmd_q
add wave -noupdate -color Pink /coh_TB/snoop_valid
add wave -noupdate -color Pink /coh_TB/snoop_flush
add wave -noupdate -divider Memory
add wave -noupdate -color Gold /coh_TB/mem_valid
add wave -noupdate -color Gold /coh_TB/mem_we
add wave -noupdate -color Gold -radix hexadecimal /coh_TB/mem_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2961 ns}
