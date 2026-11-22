onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /cache_system_TB/clk
add wave -noupdate -divider Generator
add wave -noupdate -color Cyan /cache_system_TB/start
add wave -noupdate -color Cyan -radix unsigned /cache_system_TB/pattern_sel
add wave -noupdate -color Magenta /cache_system_TB/UUT/generator/state
add wave -noupdate -color Orange -radix unsigned /cache_system_TB/UUT/generator/pass
add wave -noupdate -color Orange -radix unsigned /cache_system_TB/UUT/generator/item
add wave -noupdate -color Orange -radix hexadecimal /cache_system_TB/UUT/req_addr
add wave -noupdate -color Cyan /cache_system_TB/UUT/req_we
add wave -noupdate -color Green /cache_system_TB/UUT/resp_ready
add wave -noupdate -divider Cache
add wave -noupdate -color Magenta /cache_system_TB/UUT/cache_core/ctrl/state
add wave -noupdate -color Gold /cache_system_TB/mem_valid
add wave -noupdate -color Gold /cache_system_TB/mem_we
add wave -noupdate -divider Counters
add wave -noupdate -color White -radix unsigned /cache_system_TB/hits
add wave -noupdate -color White -radix unsigned /cache_system_TB/misses
add wave -noupdate -color Red -radix unsigned /cache_system_TB/evictions
add wave -noupdate -color Green /cache_system_TB/done
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
WaveRestoreZoom {0 ps} {65520 ns}
