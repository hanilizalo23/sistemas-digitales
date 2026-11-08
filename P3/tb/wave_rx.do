onerror {resume}
radix define tx_states {
    "3'd0" "IDLE",
    "3'd1" "START",
    "3'd2" "DATA",
    "3'd3" "PARITY",
    "3'd4" "STOP",
    -default unsigned
}
radix define rx_states {
    "2'd0" "IDLE",
    "2'd1" "START",
    "2'd2" "DATA",
    "2'd3" "STOP",
    -default unsigned
}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /uart_rx_TB/clk
add wave -noupdate -color Green /uart_rx_TB/rx
add wave -noupdate -color Green /uart_rx_TB/UUT/rx_sync
add wave -noupdate -divider FSM
add wave -noupdate -color Magenta -radix rx_states /uart_rx_TB/UUT/fsm/state
add wave -noupdate -color Pink /uart_rx_TB/UUT/baud_tick
add wave -noupdate -color Pink -radix unsigned /uart_rx_TB/UUT/bit_count
add wave -noupdate -color Pink /uart_rx_TB/UUT/store
add wave -noupdate -divider Datapath
add wave -noupdate -color Gold -radix binary /uart_rx_TB/UUT/sipo_q
add wave -noupdate -divider Outputs
add wave -noupdate -color Orange -radix hexadecimal /uart_rx_TB/rx_data
add wave -noupdate -color Cyan /uart_rx_TB/rx_flag
add wave -noupdate -color Cyan /uart_rx_TB/rx_flag_clr
add wave -noupdate -color Red /uart_rx_TB/parity_error
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
WaveRestoreZoom {0 ps} {11760 ns}
