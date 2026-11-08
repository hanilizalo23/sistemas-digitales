//=============================================================
// uart
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Full duplex UART, with the required interface: transmitter and receiver work independently on the same clock
// Frame: 8 data bits, even parity, 1 stop bit
//=============================================================

module uart #(
	parameter BIT_CYCLES = 5208 // 50 MHz / 9600 baud
) (
	input  wire       clk,
	input  wire       n_rst, // active low
	input  wire [7:0] Tx_Data,
	input  wire       tx_send,
	input  wire       rx,
	input  wire       rx_flag_clr,
	output wire       tx,
	output wire       parity_error,
	output wire       rx_flag,
	output wire [7:0] Rx_Data
);

	// the blocks reset active high
	wire rst = ~n_rst;

	uart_tx #(.BIT_CYCLES(BIT_CYCLES)) transmitter (
		.clk(clk), 
		.rst(rst), 
		.tx_send(tx_send),
		.tx_data(Tx_Data), 
		.tx(tx)
	);

	uart_rx #(.BIT_CYCLES(BIT_CYCLES)) receiver (
		.clk(clk), 
		.rst(rst), 
		.rx(rx), 
		.rx_flag_clr(rx_flag_clr),
		.rx_data(Rx_Data), 
		.rx_flag(rx_flag), 
		.parity_error(parity_error)
	);

endmodule
