//=============================================================
// debouncer_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/18/2026
//-------------------------------------------------------------
// Presses and releases the button with bounces before settling, to check that the output changes only once per press, after the input has been stable for 2^(N-1) cycles
//
// N is set to 4 so the output reacts after 8 stable cycles instead of about a million
// Stimuli change on the falling edge, so the design reads them stable on the rising edge
//=============================================================

`timescale 1ns/1ps
module debouncer_TB;

	reg  clk, reset_n, button_in;
	wire button_out;

	debouncer #(.N(4)) UUT (
		.clk(clk), 
        .reset_n(reset_n),
		.button_in(button_in), 
        .button_out(button_out)
	);

	// 20 ns clock
	always #10 clk = ~clk;

	// internal signals included to follow the counter
	initial $monitor("%4d ns | in=%b q1=%b q2=%b count=%0d out=%b",
	                 $time, button_in, UUT.q1, UUT.q2, UUT.count, button_out);

	// keep the current inputs for a number of clock cycles
	task hold(input integer cycles);
		repeat (cycles) @(negedge clk);
	endtask

	initial begin
		clk = 1'b0; reset_n = 1'b0; button_in = 1'b0;

		// reset
		hold(2);
		reset_n = 1'b1;

		// button released and stable
		hold(10);

		// press: bounces every 2 cycles, then stays high
		button_in = 1'b1; hold(2);
		button_in = 1'b0; hold(2);
		button_in = 1'b1; hold(2);
		button_in = 1'b0; hold(2);
		button_in = 1'b1; hold(14);

		// release: bounces, then stays low
		button_in = 1'b0; hold(2);
		button_in = 1'b1; hold(2);
		button_in = 1'b0; hold(14);

		$stop;
	end

endmodule
