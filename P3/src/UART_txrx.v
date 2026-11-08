//=============================================================
// UART_txrx
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Top level for the FPGA: connects the UART to the board and to the PmodUSB-UART on the GPIO header
//
//   SW[7:0]      character to send (ASCII code)
//   KEY0         send it (one character per press)
//   KEY1         clear rx_flag
//   KEY3         reset, active low like the button itself
//   HEX1, HEX0   last character received, in hexadecimal
//   HEX3, HEX2   character set on the switches
//   LEDR0        rx_flag: a new character arrived
//   LEDR1        parity_error
//   UART_TX      GPIO[0], header pin 1 -> Pmod RXD (pin 2)
//   UART_RX      GPIO[1], header pin 2 <- Pmod TXD (pin 3)
//=============================================================

module UART_txrx (
	input  wire       CLOCK_50,
	input  wire [3:0] KEY,
	input  wire [7:0] SW,
	input  wire       UART_RX,
	output wire       UART_TX,
	output wire [6:0] HEX0,
	output wire [6:0] HEX1,
	output wire [6:0] HEX2,
	output wire [6:0] HEX3,
	output wire [1:0] LEDR
);

	wire       n_rst = KEY[3];
	wire       rst   = ~n_rst;
	wire       send_sync, send_pulse, clr_sync;
	wire [7:0] rx_data;

	// buttons are active low and not related to the clock: invert, then synchronize
	synchronizer #(.RESET_VALUE(0)) send_synchronizer (
		.clk(CLOCK_50), 
		.rst(rst), 
		.async_in(~KEY[0]), 
		.sync_out(send_sync)
	);

	synchronizer #(.RESET_VALUE(0)) clr_synchronizer (
		.clk(CLOCK_50), 
		.rst(rst), 
		.async_in(~KEY[1]), 
		.sync_out(clr_sync)
	);

	// one character per press
	edge_detector send_edge (
		.clk(CLOCK_50), 
		.rst(rst), 
		.level_in(send_sync), 
		.pulse(send_pulse)
	);

	uart #(.BIT_CYCLES(5208)) uart_core (
		.clk(CLOCK_50), 
		.n_rst(n_rst),
		.Tx_Data(SW[7:0]), 
		.tx_send(send_pulse),
		.rx(UART_RX), 
		.rx_flag_clr(clr_sync),
		.tx(UART_TX), 
		.parity_error(LEDR[1]),
		.rx_flag(LEDR[0]), 
		.Rx_Data(rx_data)
	);

	// received character
	hex7seg hex0_dec (
		.value(rx_data[3:0]), 
		.blank(1'b0), 
		.seg(HEX0)
	);
	hex7seg hex1_dec (
		.value(rx_data[7:4]), 
		.blank(1'b0), 
		.seg(HEX1)
	);

	// character to send
	hex7seg hex2_dec (
		.value(SW[3:0]), 
		.blank(1'b0), 
		.seg(HEX2)
	);
	hex7seg hex3_dec (
		.value(SW[7:4]), 
		.blank(1'b0), 
		.seg(HEX3)
	);

endmodule
