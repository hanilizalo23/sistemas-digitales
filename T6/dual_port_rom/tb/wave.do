onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /dual_port_rom_TB/clk
add wave -noupdate -divider {Port A}
add wave -noupdate -color Orange -radix unsigned /dual_port_rom_TB/addr_a
add wave -noupdate -color Green -radix ascii /dual_port_rom_TB/q_a
add wave -noupdate -divider {Port B}
add wave -noupdate -color Gold -radix unsigned /dual_port_rom_TB/addr_b
add wave -noupdate -color Cyan -radix ascii /dual_port_rom_TB/q_b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {668644 ps} 0}
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
WaveRestoreZoom {0 ps} {693 ns}
