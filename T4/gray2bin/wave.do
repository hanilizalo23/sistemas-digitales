onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color {Cornflower Blue} -radix decimal /gray2bin_tb/i
add wave -noupdate -color Gold -expand -subitemconfig {{/gray2bin_tb/g[3]} {-color Gold} {/gray2bin_tb/g[2]} {-color Gold} {/gray2bin_tb/g[1]} {-color Gold} {/gray2bin_tb/g[0]} {-color Gold}} /gray2bin_tb/g
add wave -noupdate -color {Medium Violet Red} -expand -subitemconfig {{/gray2bin_tb/b[3]} {-color {Medium Violet Red}} {/gray2bin_tb/b[2]} {-color {Medium Violet Red}} {/gray2bin_tb/b[1]} {-color {Medium Violet Red}} {/gray2bin_tb/b[0]} {-color {Medium Violet Red}}} /gray2bin_tb/b
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
