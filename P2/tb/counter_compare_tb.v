`timescale 1ns/1ps

//=============================================================
// counter_compare_tb
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/10/2026
//-------------------------------------------------------------
// Quick check of the counter block before instantiating it: counting up, wrapping, pausing, loading, counting down, and a non zero reset value
//
// Stimuli change on the falling edge, so the counter reads them stable on the next rising edge
//=============================================================

module counter_compare_tb;

	reg       clk, rst, enable, count_down, load;
	reg [3:0] load_value;

	wire [3:0] count, count_r9;
	wire       max_hit, max_hit_r9;

	// default reset value (zero)
	counter_compare #(.SIZE(4), .MAX_COUNT(9)) dut (
		.clk(clk), .rst(rst), .enable(enable),
		.count_down(count_down), .load(load), .load_value(load_value),
		.count(count), .max_hit(max_hit)
	);

	// reset value of nine, as used for hundredths and tenths
	counter_compare #(.SIZE(4), .MAX_COUNT(9), .RESET_VALUE(9)) dut_r9 (
		.clk(clk), .rst(rst), .enable(enable),
		.count_down(count_down), .load(load), .load_value(load_value),
		.count(count_r9), .max_hit(max_hit_r9)
	);

	// 10 ns clock
	always #5 clk = ~clk;

	// one row of results
	task show;
		$display("%6t |   %0d   |    %b    |    %0d", $time, count, max_hit, count_r9);
	endtask

	initial begin
		clk = 0; rst = 1; enable = 0;
		count_down = 0; load = 0; load_value = 4'd0;

		$display("  time | count | max_hit | count_r9");

		// in reset: default counter at 0, the other one at 9
		$display("--- in reset ---");
		@(negedge clk); show;

		// release reset and count up past the wrap
		$display("--- counting up ---");
		rst = 0; enable = 1;
		repeat (12) begin
			@(negedge clk); show;
		end

		// pause: the values must hold
		$display("--- paused ---");
		enable = 0;
		repeat (3) begin
			@(negedge clk); show;
		end

		// load a preset value
		$display("--- load 7 ---");
		load = 1; load_value = 4'd7;
		@(negedge clk); show;
		load = 0;

		// count down past zero
		$display("--- counting down ---");
		enable = 1; count_down = 1;
		repeat (10) begin
			@(negedge clk); show;
		end

		$display("done");
		$stop;
	end

endmodule
