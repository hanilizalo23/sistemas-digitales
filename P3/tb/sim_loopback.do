#=============================================================
# sim_loopback.do  -  full UART, tx wired back into rx
# run from the tb folder:  do sim_loopback.do
#=============================================================

catch {quit -sim}
vlib work
vlog ../src/*.v
vlog *.v
vsim -voptargs=+acc work.uart_loopback_TB
config wave -signalnamewidth 1

radix define tx_states {
    3'd0 "IDLE", 3'd1 "START", 3'd2 "DATA", 3'd3 "PARITY", 3'd4 "STOP",
    -default unsigned
}
radix define rx_states {
    2'd0 "IDLE", 2'd1 "START", 2'd2 "DATA", 2'd3 "STOP",
    -default unsigned
}

add wave -color Yellow                     /uart_loopback_TB/clk
add wave -color Cyan                       /uart_loopback_TB/tx_send
add wave -color Orange  -radix ascii       /uart_loopback_TB/tx_data
add wave -color Magenta -radix tx_states   /uart_loopback_TB/UUT/transmitter/fsm/state
add wave -color Green                      /uart_loopback_TB/line
add wave -color Magenta -radix rx_states   /uart_loopback_TB/UUT/receiver/fsm/state
add wave -color Orange  -radix ascii       /uart_loopback_TB/rx_data
add wave -color Cyan                       /uart_loopback_TB/rx_flag
add wave -color Red                        /uart_loopback_TB/parity_error

run -all
wave zoom full
