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
add wave -noupdate -color Yellow /uart_loopback_TB/clk
add wave -noupdate -color Cyan /uart_loopback_TB/tx_send
add wave -noupdate -color Orange -radix ascii /uart_loopback_TB/tx_data
add wave -noupdate -color Magenta -radix tx_states /uart_loopback_TB/UUT/transmitter/fsm/state
add wave -noupdate -color Green /uart_loopback_TB/line
add wave -noupdate -color Magenta -radix rx_states /uart_loopback_TB/UUT/receiver/fsm/state
add wave -noupdate -color Orange -radix ascii /uart_loopback_TB/rx_data
add wave -noupdate -color Cyan /uart_loopback_TB/rx_flag
add wave -noupdate -color Red /uart_loopback_TB/parity_error
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
WaveRestoreZoom {0 ps} {16254 ns}
