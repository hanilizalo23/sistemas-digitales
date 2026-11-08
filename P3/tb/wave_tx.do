onerror {resume}
radix define tx_states {
    "3'd0" "IDLE",
    "3'd1" "START",
    "3'd2" "DATA",
    "3'd3" "PARITY",
    "3'd4" "STOP",
    -default unsigned
}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /uart_tx_TB/clk
add wave -noupdate -color Cyan /uart_tx_TB/tx_send
add wave -noupdate -color Orange -radix hexadecimal /uart_tx_TB/tx_data
add wave -noupdate -divider FSM
add wave -noupdate -color Magenta -radix tx_states /uart_tx_TB/UUT/fsm/state
add wave -noupdate -color Pink /uart_tx_TB/UUT/baud_tick
add wave -noupdate -color Pink -radix unsigned /uart_tx_TB/UUT/bit_count
add wave -noupdate -color Pink -radix unsigned /uart_tx_TB/UUT/tx_sel
add wave -noupdate -divider Datapath
add wave -noupdate -color Gold -radix binary /uart_tx_TB/UUT/piso/q
add wave -noupdate -color Gold /uart_tx_TB/UUT/parity_q
add wave -noupdate -divider Line
add wave -noupdate -color Green /uart_tx_TB/tx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {7602 ns}
