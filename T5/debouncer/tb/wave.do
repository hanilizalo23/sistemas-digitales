onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /debouncer_TB/clk
add wave -noupdate -color Cyan /debouncer_TB/reset_n
add wave -noupdate -color Orange /debouncer_TB/button_in
add wave -noupdate -color Pink /debouncer_TB/UUT/q1
add wave -noupdate -color Violet /debouncer_TB/UUT/q2
add wave -noupdate -color Magenta /debouncer_TB/UUT/changed
add wave -noupdate -color White -radix unsigned /debouncer_TB/UUT/count
add wave -noupdate -color Green /debouncer_TB/button_out
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
WaveRestoreZoom {0 ps} {1092 ns}
