//=============================================================
// uart_rx_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Drives frames into the rx line the way a PC would, and checks what the receiver stores
//
//   1. 'A' with correct parity   -> Rx_Data 41h, no error
//   2. clear rx_flag
//   3. 'C' with wrong parity     -> Rx_Data 43h, parity_error
//   4. a short low glitch        -> ignored, nothing changes
//
// One bit lasts 16 clock cycles here instead of 5208
//=============================================================

`timescale 1ns/1ps
module uart_rx_TB;

	localparam BIT_CYCLES = 16;

	reg        clk, rst, rx, rx_flag_clr;
	wire [7:0] rx_data;
	wire       rx_flag, parity_error;

	uart_rx #(.BIT_CYCLES(BIT_CYCLES)) UUT (
		.clk(clk), 
		.rst(rst), 
		.rx(rx), 
		.rx_flag_clr(rx_flag_clr),
		.rx_data(rx_data), 
		.rx_flag(rx_flag), 
		.parity_error(parity_error)
	);

	// 20 ns clock (50 MHz)
	always #10 clk = ~clk;

	// drive one frame, bad_parity flips the parity bit
	task send_frame(input [7:0] value, input bad_parity);
		integer i;
		begin
			@(negedge clk) rx = 1'b0;               // start
			repeat (BIT_CYCLES) @(negedge clk);
			for (i = 0; i < 8; i = i + 1) begin
				rx = value[i];                      // data, bit 0 first
				repeat (BIT_CYCLES) @(negedge clk);
			end
			rx = (^value) ^ bad_parity;             // parity
			repeat (BIT_CYCLES) @(negedge clk);
			rx = 1'b1;                              // stop
			repeat (BIT_CYCLES) @(negedge clk);
		end
	endtask

	task show(input [8*24:1] label);
		$display("%6t | %-22s | rx_data=%h ('%c') rx_flag=%b parity_error=%b",
		         $time, label, rx_data, rx_data, rx_flag, parity_error);
	endtask

	initial begin
		clk = 1'b0; rst = 1'b1; rx = 1'b1; rx_flag_clr = 1'b0;
		repeat (2) @(negedge clk);
		rst = 1'b0;
		repeat (4) @(negedge clk);
		show("after reset");

		send_frame(8'h41, 1'b0);
		show("'A', good parity");

		@(negedge clk) rx_flag_clr = 1'b1;
		@(negedge clk) rx_flag_clr = 1'b0;
		show("rx_flag cleared");

		send_frame(8'h43, 1'b1);
		show("'C', wrong parity");

		@(negedge clk) rx_flag_clr = 1'b1;
		@(negedge clk) rx_flag_clr = 1'b0;

		// glitch shorter than half a bit: must not start a frame
		@(negedge clk) rx = 1'b0;
		repeat (3) @(negedge clk) rx = 1'b1;
		repeat (BIT_CYCLES * 12) @(negedge clk);
		show("after a glitch");

		$stop;
	end

endmodule
