//=============================================================
// time_chain
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/10/2026
//-------------------------------------------------------------
// The whole time count, built as a cascade of counter_compare blocks: HH:MM:SS.cc
//
// Each stage is enabled by the wrap of the stage below it, so a digit only advances when the one to its right rolls over
// The clock divider is instantiated twice with different limits, and a mux picks between normal and fast speed, which is what makes the count testable
//
// Ports:
//   clk        : 50 MHz FPGA clock
//   rst        : synchronous reset, active high
//   run        : counts while high, holds while low
//   count_down : 0 stopwatch, 1 timer
//   fast       : 1 runs the count 100 times faster
//   load       : loads every stage from the preset inputs
//   preset_*   : values used when load is high
//   *_out      : current value of each digit
//   time_zero  : high when the whole count is zero
//=============================================================

module time_chain (
	input  wire       clk,
	input  wire       rst,
	input  wire       run,
	input  wire       count_down,
	input  wire       fast,
	input  wire       load,

	input  wire [3:0] preset_hund,
	input  wire [3:0] preset_tenth,
	input  wire [3:0] preset_sec_u,
	input  wire [2:0] preset_sec_t,
	input  wire [3:0] preset_min_u,
	input  wire [2:0] preset_min_t,
	input  wire [3:0] preset_hr_u,
	input  wire [1:0] preset_hr_t,

	output wire [3:0] hund_out,
	output wire [3:0] tenth_out,
	output wire [3:0] sec_u_out,
	output wire [2:0] sec_t_out,
	output wire [3:0] min_u_out,
	output wire [2:0] min_t_out,
	output wire [3:0] hr_u_out,
	output wire [1:0] hr_t_out,

	output wire       time_zero
);

	//---------------------------------------------------------
	// clock dividers: 50 MHz down to 100 Hz, or 100x faster
	wire [18:0] div_slow_count, div_fast_count;
	wire        tick_slow, tick_fast;

	counter_compare #(.SIZE(19), .MAX_COUNT(499999)) divider_slow (
		.clk(clk), 
		.rst(rst), 
		.enable(run), 
		.count_down(1'b0),
		.load(1'b0), 
		.load_value(19'd0),
		.count(div_slow_count), 
		.max_hit(tick_slow)
	);

	counter_compare #(.SIZE(19), .MAX_COUNT(4999)) divider_fast (
		.clk(clk), 
		.rst(rst), 
		.enable(run), 
		.count_down(1'b0),
		.load(1'b0), 
		.load_value(19'd0),
		.count(div_fast_count), 
		.max_hit(tick_fast)
	);

	// one tick per hundredth of a second, at the selected speed
	wire tick = fast ? tick_fast : tick_slow;

	//---------------------------------------------------------
	// digit chain: each stage advances on the wrap below it
	
	wire hund_hit, tenth_hit, sec_u_hit, sec_t_hit, min_u_hit, min_t_hit, hr_u_hit, hr_t_hit;

	counter_compare #(.SIZE(4), .MAX_COUNT(9), .RESET_VALUE(9)) hundredths (
		.clk(clk), 
		.rst(rst), 
		.enable(tick), 
		.count_down(count_down),
		.load(load), 
		.load_value(preset_hund),
		.count(hund_out), 
		.max_hit(hund_hit)
	);

	counter_compare #(.SIZE(4), .MAX_COUNT(9), .RESET_VALUE(9)) tenths (
		.clk(clk), 
		.rst(rst), 
		.enable(hund_hit), 
		.count_down(count_down),
		.load(load), 
		.load_value(preset_tenth),
		.count(tenth_out), 
		.max_hit(tenth_hit)
	);

	counter_compare #(.SIZE(4), .MAX_COUNT(9)) sec_units (
		.clk(clk), 
		.rst(rst), 
		.enable(tenth_hit), 
		.count_down(count_down),
		.load(load), 
		.load_value(preset_sec_u),
		.count(sec_u_out), 
		.max_hit(sec_u_hit)
	);

	counter_compare #(.SIZE(3), .MAX_COUNT(5)) sec_tens (
		.clk(clk), 
		.rst(rst), 
		.enable(sec_u_hit), 
		.count_down(count_down),
		.load(load), 
		.load_value(preset_sec_t),
		.count(sec_t_out), 
		.max_hit(sec_t_hit)
	);

	counter_compare #(.SIZE(4), .MAX_COUNT(9)) min_units (
		.clk(clk), 
		.rst(rst), 
		.enable(sec_t_hit), 
		.count_down(count_down),
		.load(load), 
		.load_value(preset_min_u),
		.count(min_u_out), 
		.max_hit(min_u_hit)
	);

	counter_compare #(.SIZE(3), .MAX_COUNT(5)) min_tens (
		.clk(clk), 
		.rst(rst), 
		.enable(min_u_hit), 
		.count_down(count_down),
		.load(load), 
		.load_value(preset_min_t),
		.count(min_t_out), 
		.max_hit(min_t_hit)
	);

	counter_compare #(.SIZE(4), .MAX_COUNT(9)) hour_units (
		.clk(clk), 
		.rst(rst), 
		.enable(min_t_hit), 
		.count_down(count_down),
		.load(load), 
		.load_value(preset_hr_u),
		.count(hr_u_out), 
		.max_hit(hr_u_hit)
	);

	counter_compare #(.SIZE(2), .MAX_COUNT(2)) hour_tens (
		.clk(clk), 
		.rst(rst), 
		.enable(hr_u_hit), 
		.count_down(count_down),
		.load(load), 
		.load_value(preset_hr_t),
		.count(hr_t_out), 
		.max_hit(hr_t_hit)
	);

	// used by the timer to know when it finished
	assign time_zero = (hund_out  == 4'd0) && (tenth_out == 4'd0) && (sec_u_out == 4'd0) && (sec_t_out == 3'd0) &&
	                   (min_u_out == 4'd0) && (min_t_out == 3'd0) && (hr_u_out  == 4'd0) && (hr_t_out  == 2'd0);

endmodule
