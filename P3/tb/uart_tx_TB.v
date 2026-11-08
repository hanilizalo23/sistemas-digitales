//=============================================================
// uart_tx_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Sends two characters and reads them back from the tx line, sampling in the middle of each bit, like a receiver would
//
// One bit lasts 16 clock cycles here instead of 5208, so the simulation stays short, the design doesn't change
//
//   'A' = 41h = 0100_0001: two ones,   parity bit 0
//   'C' = 43h = 0100_0011: three ones, parity bit 1
//=============================================================

`timescale 1ns/1ps
module uart_tx_TB;

	localparam BIT_CYCLES = 16;

	reg        clk, rst, tx_send;
	reg  [7:0] tx_data;
	wire       tx;

	uart_tx #(.BIT_CYCLES(BIT_CYCLES)) UUT (
		.clk(clk), 
		.rst(rst), 
		.tx_send(tx_send),
		.tx_data(tx_data), 
		.tx(tx)
	);

	// 20 ns clock (50 MHz)
	always #10 clk = ~clk;

	// send one character: tx_send high for one cycle
	task send(input [7:0] value);
		begin
			@(negedge clk);
			tx_data = value; tx_send = 1'b1;
			@(negedge clk);
			tx_send = 1'b0;
		end
	endtask

	// read one frame from the line, sampling mid bit
	task read_frame;
		reg [10:0] frame;
		integer i;
		begin
			@(negedge tx);                        // start bit begins
			repeat (BIT_CYCLES/2) @(posedge clk); // middle of start bit
			for (i = 0; i < 11; i = i + 1) begin
				frame[i] = tx;
				if (i < 10) repeat (BIT_CYCLES) @(posedge clk);
			end
			$display("%6t | start=%b data=%h ('%c') parity=%b stop=%b",
			         $time, frame[0], frame[8:1], frame[8:1], frame[9], frame[10]);
		end
	endtask

	initial begin
		clk = 1'b0; rst = 1'b1; tx_send = 1'b0; tx_data = 8'h00;
		repeat (2) @(negedge clk);
		rst = 1'b0;
		repeat (4) @(negedge clk);

		fork
			send(8'h41);
			read_frame;
		join
		repeat (8) @(negedge clk);

		fork
			send(8'h43);
			read_frame;
		join
		repeat (8) @(negedge clk);

		$stop;
	end

endmodule
