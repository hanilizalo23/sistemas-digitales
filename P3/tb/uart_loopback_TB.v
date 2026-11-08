//=============================================================
// uart_loopback_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// The full UART with its tx line wired back into its rx line:
// every character sent must come back in Rx_Data, with rx_flag set and no parity error
//
// BIT_CYCLES can be changed to 5208 to check the real timing (much slower to simulate)
//=============================================================

`timescale 1ns/1ps
module uart_loopback_TB;

	parameter BIT_CYCLES = 16;

	reg        clk, n_rst, tx_send, rx_flag_clr;
	reg  [7:0] tx_data;
	wire       line;                 // tx wired to rx
	wire       rx_flag, parity_error;
	wire [7:0] rx_data;

	integer i;
	reg [8*4:1] text;

	uart #(.BIT_CYCLES(BIT_CYCLES)) UUT (
		.clk(clk), 
		.n_rst(n_rst),
		.Tx_Data(tx_data), 
		.tx_send(tx_send),
		.rx(line), 
		.rx_flag_clr(rx_flag_clr),
		.tx(line), 
		.parity_error(parity_error),
		.rx_flag(rx_flag), 
		.Rx_Data(rx_data)
	);

	// 20 ns clock (50 MHz)
	always #10 clk = ~clk;

	initial begin
		clk = 1'b0; n_rst = 1'b0; tx_send = 1'b0;
		rx_flag_clr = 1'b0; tx_data = 8'h00;
		text = "Nely";
		repeat (2) @(negedge clk);
		n_rst = 1'b1;
		repeat (4) @(negedge clk);

		for (i = 4; i >= 1; i = i - 1) begin
			// send one character
			@(negedge clk);
			tx_data = text[8*i -: 8]; tx_send = 1'b1;
			@(negedge clk) tx_send = 1'b0;

			// wait until it comes back
			@(posedge rx_flag);
			@(negedge clk);
			$display("%8t | sent %h ('%c') -> received %h ('%c') parity_error=%b",
			         $time, tx_data, tx_data, rx_data, rx_data, parity_error);

			// clear the flag before the next one
			rx_flag_clr = 1'b1;
			@(negedge clk) rx_flag_clr = 1'b0;
			repeat (BIT_CYCLES) @(negedge clk);
		end

		$stop;
	end

endmodule
