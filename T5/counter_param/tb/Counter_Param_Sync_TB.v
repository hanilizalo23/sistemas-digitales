`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Nelida Hernandez, ITESO, 10/18/2026
// Testbench for the 2^n counter with synchronous reset
// Each phase exercises one input: reset, enable while counting (including the wrap from 15 to 0), enable low, and reset while enable is low
// Stimuli change on the falling edge, so the counter reads them stable on the next rising edge
//////////////////////////////////////////////////////////////////////////////////

module Counter_Param_Sync_TB;

	localparam n = 4;

	reg clk, rst, enable;
	wire [n-1:0] Q;

	Counter_Param_Sync #(.n(n)) UUT (.clk(clk), .rst(rst), .enable(enable), .Q(Q));

	// 20 ns clock
	always #10 clk = ~clk;

	initial $monitor("%5d ns | rst=%b enable=%b Q=%0d", $time, rst, enable, Q);

	initial begin
		clk = 1'b0; rst = 1'b1; enable = 1'b0;

		// reset: Q clears on the first rising edge
		@(negedge clk) rst = 1'b0;

		// enable high: counts up to 15 and wraps back to 0
		enable = 1'b1;
		repeat (18) @(negedge clk);

		// enable low: Q holds its value
		enable = 1'b0;
		repeat (3) @(negedge clk);

		// reset with enable still low: clears on the next rising edge
		rst = 1'b1;
		@(negedge clk) rst = 1'b0;

		// enable high again: counts from zero
		enable = 1'b1;
		repeat (4) @(negedge clk);

		$stop;
	end

endmodule