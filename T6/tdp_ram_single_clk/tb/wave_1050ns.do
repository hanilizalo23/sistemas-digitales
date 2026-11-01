onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /tdp_ram_single_clk_TB/clk
add wave -noupdate -divider {Port A}
add wave -noupdate -color Cyan /tdp_ram_single_clk_TB/we_a
add wave -noupdate -color Orange -radix unsigned /tdp_ram_single_clk_TB/addr_a
add wave -noupdate -color Pink -radix hexadecimal /tdp_ram_single_clk_TB/data_a
add wave -noupdate -color Green -radix hexadecimal /tdp_ram_single_clk_TB/q_a
add wave -noupdate -divider {Port B}
add wave -noupdate -color Violet /tdp_ram_single_clk_TB/we_b
add wave -noupdate -color Gold -radix unsigned /tdp_ram_single_clk_TB/addr_b
add wave -noupdate -color Salmon -radix hexadecimal /tdp_ram_single_clk_TB/data_b
add wave -noupdate -color White -radix hexadecimal /tdp_ram_single_clk_TB/q_b
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
WaveRestoreZoom {990 ns} {1050 ns}
