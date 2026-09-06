onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group inputs /demux1to4_tb/d
add wave -noupdate -expand -group inputs -expand /demux1to4_tb/s
add wave -noupdate -expand -group outputs /demux1to4_tb/y0
add wave -noupdate -expand -group outputs /demux1to4_tb/y1
add wave -noupdate -expand -group outputs /demux1to4_tb/y2
add wave -noupdate -expand -group outputs /demux1to4_tb/y3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {84 ns}
