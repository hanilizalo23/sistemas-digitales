onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /Counter_02Limit_ovf_TB/clk
add wave -noupdate -color Cyan /Counter_02Limit_ovf_TB/rst
add wave -noupdate -color Magenta /Counter_02Limit_ovf_TB/enable
add wave -noupdate -color Green -radix unsigned /Counter_02Limit_ovf_TB/Q
add wave -noupdate -color Orange /Counter_02Limit_ovf_TB/overflow
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
WaveRestoreZoom {0 ps} {420 ns}
