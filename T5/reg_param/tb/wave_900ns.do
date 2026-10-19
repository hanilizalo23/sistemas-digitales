onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /Reg_Param_TB/clk
add wave -noupdate -color Cyan /Reg_Param_TB/rst
add wave -noupdate -color Magenta /Reg_Param_TB/enable
add wave -noupdate -color Orange -radix hexadecimal /Reg_Param_TB/D
add wave -noupdate -color Green -radix hexadecimal /Reg_Param_TB/Q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {909590 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {780 ns} {910 ns}
