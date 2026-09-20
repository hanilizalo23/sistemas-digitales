onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /signed_to_bcd_tb/value
add wave -noupdate /signed_to_bcd_tb/is_neg
add wave -noupdate /signed_to_bcd_tb/hundreds
add wave -noupdate /signed_to_bcd_tb/tens
add wave -noupdate /signed_to_bcd_tb/units
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 194
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
WaveRestoreZoom {0 ps} {126 ns}
