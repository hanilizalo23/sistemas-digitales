onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /Shift_Register_R_Param_TB/clk
add wave -noupdate -color Cyan /Shift_Register_R_Param_TB/rst
add wave -noupdate -color Magenta /Shift_Register_R_Param_TB/enable
add wave -noupdate -color Orange /Shift_Register_R_Param_TB/d
add wave -noupdate -color Green -radix binary /Shift_Register_R_Param_TB/Q
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
WaveRestoreZoom {0 ps} {80 ns}
