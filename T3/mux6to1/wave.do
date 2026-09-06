onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mux6to1_tb/s
add wave -noupdate -expand -group inputs /mux6to1_tb/d0
add wave -noupdate -expand -group inputs /mux6to1_tb/d1
add wave -noupdate -expand -group inputs /mux6to1_tb/d2
add wave -noupdate -expand -group inputs /mux6to1_tb/d3
add wave -noupdate -expand -group inputs /mux6to1_tb/d4
add wave -noupdate -expand -group inputs /mux6to1_tb/d5
add wave -noupdate -expand -group output /mux6to1_tb/y
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
WaveRestoreZoom {0 ps} {168 ns}
