onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /rom_sync_TB/clk
add wave -noupdate -color Orange -radix unsigned /rom_sync_TB/address
add wave -noupdate -color Green -radix ascii /rom_sync_TB/q_case
add wave -noupdate -color Cyan -radix ascii /rom_sync_TB/q_array
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
WaveRestoreZoom {0 ps} {1 us}
