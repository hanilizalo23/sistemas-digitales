onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /hex7seg_tb/hex_value
add wave -noupdate -expand -group inputs /hex7seg_tb/w
add wave -noupdate -expand -group inputs /hex7seg_tb/x
add wave -noupdate -expand -group inputs /hex7seg_tb/y
add wave -noupdate -expand -group inputs /hex7seg_tb/z
add wave -noupdate -expand -group outputs /hex7seg_tb/a
add wave -noupdate -expand -group outputs /hex7seg_tb/b
add wave -noupdate -expand -group outputs /hex7seg_tb/c
add wave -noupdate -expand -group outputs /hex7seg_tb/d
add wave -noupdate -expand -group outputs /hex7seg_tb/e
add wave -noupdate -expand -group outputs /hex7seg_tb/f
add wave -noupdate -expand -group outputs /hex7seg_tb/g
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 171
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {168 ns}
