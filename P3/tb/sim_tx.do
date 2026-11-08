#=============================================================
# sim_tx.do  -  transmitter simulation
# run from the tb folder:  do sim_tx.do
#=============================================================

catch {quit -sim}
vlib work
vlog ../src/*.v
vlog *.v
vsim -voptargs=+acc work.uart_tx_TB
config wave -signalnamewidth 1

# show the FSM states by name
radix define tx_states {
    3'd0 "IDLE",
    3'd1 "START",
    3'd2 "DATA",
    3'd3 "PARITY",
    3'd4 "STOP",
    -default unsigned
}

add wave -color Yellow                     /uart_tx_TB/clk
add wave -color Cyan                       /uart_tx_TB/tx_send
add wave -color Orange  -radix hex         /uart_tx_TB/tx_data
add wave -divider "FSM"
add wave -color Magenta -radix tx_states   /uart_tx_TB/UUT/fsm/state
add wave -color Pink                       /uart_tx_TB/UUT/baud_tick
add wave -color Pink    -radix unsigned    /uart_tx_TB/UUT/bit_count
add wave -color Pink    -radix unsigned    /uart_tx_TB/UUT/tx_sel
add wave -divider "Datapath"
add wave -color Gold    -radix binary      /uart_tx_TB/UUT/piso/q
add wave -color Gold                       /uart_tx_TB/UUT/parity_q
add wave -divider "Line"
add wave -color Green                      /uart_tx_TB/tx

run -all
wave zoom full
