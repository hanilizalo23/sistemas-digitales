#=============================================================
# sim_rx.do  -  receiver simulation
# run from the tb folder:  do sim_rx.do
#=============================================================

catch {quit -sim}
vlib work
vlog ../src/*.v
vlog *.v
vsim -voptargs=+acc work.uart_rx_TB
config wave -signalnamewidth 1

# show the FSM states by name
radix define rx_states {
    2'd0 "IDLE",
    2'd1 "START",
    2'd2 "DATA",
    2'd3 "STOP",
    -default unsigned
}

add wave -color Yellow                     /uart_rx_TB/clk
add wave -color Green                      /uart_rx_TB/rx
add wave -color Green                      /uart_rx_TB/UUT/rx_sync
add wave -divider "FSM"
add wave -color Magenta -radix rx_states   /uart_rx_TB/UUT/fsm/state
add wave -color Pink                       /uart_rx_TB/UUT/baud_tick
add wave -color Pink    -radix unsigned    /uart_rx_TB/UUT/bit_count
add wave -color Pink                       /uart_rx_TB/UUT/store
add wave -divider "Datapath"
add wave -color Gold    -radix binary      /uart_rx_TB/UUT/sipo_q
add wave -divider "Outputs"
add wave -color Orange  -radix hex         /uart_rx_TB/rx_data
add wave -color Cyan                       /uart_rx_TB/rx_flag
add wave -color Cyan                       /uart_rx_TB/rx_flag_clr
add wave -color Red                        /uart_rx_TB/parity_error

run -all
wave zoom full
