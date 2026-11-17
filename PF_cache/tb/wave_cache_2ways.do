onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /cache_TB/clk
add wave -noupdate -divider Request
add wave -noupdate -color Cyan /cache_TB/req_valid
add wave -noupdate -color Cyan /cache_TB/req_we
add wave -noupdate -color Orange -radix hexadecimal /cache_TB/req_addr
add wave -noupdate -color Orange -radix hexadecimal /cache_TB/req_wdata
add wave -noupdate -color Green /cache_TB/resp_ready
add wave -noupdate -color Green -radix hexadecimal /cache_TB/resp_rdata
add wave -noupdate -divider Control
add wave -noupdate -color Magenta /cache_TB/UUT/ctrl/state
add wave -noupdate -color Pink /cache_TB/UUT/hit
add wave -noupdate -color Pink -radix unsigned /cache_TB/UUT/hit_way
add wave -noupdate -color Pink -radix unsigned /cache_TB/UUT/victim_way
add wave -noupdate -color Pink /cache_TB/UUT/victim_dirty
add wave -noupdate -divider Memory
add wave -noupdate -color Gold /cache_TB/mem_valid
add wave -noupdate -color Gold /cache_TB/mem_we
add wave -noupdate -color Gold -radix hexadecimal /cache_TB/mem_addr
add wave -noupdate -color Gold /cache_TB/mem_ready
add wave -noupdate -divider Events
add wave -noupdate -color White /cache_TB/ev_hit
add wave -noupdate -color White /cache_TB/ev_miss
add wave -noupdate -color Red /cache_TB/ev_evict
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
WaveRestoreZoom {0 ps} {1635540 ps}
