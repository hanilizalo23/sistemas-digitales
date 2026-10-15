//=============================================================
// stopwatch_timer
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/10/2026
//-------------------------------------------------------------
// Top level of the stopwatch_timer
//
// Counts HH:MM:SS.cc up as a stopwatch, or down as a timer programmed from the switches
// Four displays show a sliding window of the count, the two on the left show the active mode
//
// Board mapping:
//   KEY0        start/pause
//   KEY1        reset
//   KEY2        stopwatch/timer mode
//   KEY3        normal/fast speed
//   SW[9:7]     timer preset, tens of minutes
//   SW[6:3]     timer preset, units of minutes
//   SW[2:0]     timer preset, tens of seconds
//   HEX3-HEX0   count
//   HEX5, HEX4  mode indicator
//   LEDR        blink when the timer ends
//=============================================================

module stopwatch_timer (
	input  wire       CLOCK_50,
	input  wire [3:0] KEY,
	input  wire [9:0] SW,
	output wire [6:0] HEX0,
	output wire [6:0] HEX1,
	output wire [6:0] HEX2,
	output wire [6:0] HEX3,
	output wire [6:0] HEX4,
	output wire [6:0] HEX5,
	output wire [9:0] LEDR
);

	localparam SEG_OFF = 7'b1111111; // all segments off, active low
	localparam SEG_C   = 7'b1000110; // letter C, stopwatch
	localparam SEG_T   = 7'b0000111; // letter t, timer
	localparam SEG_F   = 7'b0001110; // letter F, fast

	wire clk = CLOCK_50;

	// control
	wire time_zero, chain_rst, run, count_down, fast, load, leds_on;

	mode_control control_unit (
		.clk(clk), 
		.key(KEY), 
		.time_zero(time_zero),
		.chain_rst(chain_rst), 
		.run(run), 
		.count_down(count_down),
		.fast(fast), 
		.load(load), 
		.leds_on(leds_on)
	);

	// count
	wire [3:0] hund, tenth, sec_u, min_u, hr_u;
	wire [2:0] sec_t, min_t;
	wire [1:0] hr_t;

	// wrap to zero after 23:59:59.99 instead of 29:59:59.99
	wire day_wrap = (hr_t == 2'd2) && (hr_u == 4'd4);
	
	// timer preset from the switches, clamped to valid time digits
	// so an out of range switch value can't show a non decimal digit
	wire [2:0] preset_min_t = (SW[9:7] > 3'd5) ? 3'd5 : SW[9:7];
	wire [3:0] preset_min_u = (SW[6:3] > 4'd9) ? 4'd9 : SW[6:3];
	wire [2:0] preset_sec_t = (SW[2:0] > 3'd5) ? 3'd5 : SW[2:0];

	time_chain count_unit (
		.clk(clk), 
		.rst(chain_rst | day_wrap),
		.run(run), 
		.count_down(count_down), 
		.fast(fast), 
		.load(load),

		// clamped timer preset, the rest starts at zero
		.preset_hund(4'd0),  
		.preset_tenth(4'd0),
		.preset_sec_u(4'd0), 
		.preset_sec_t(preset_sec_t),
		.preset_min_u(preset_min_u), 
		.preset_min_t(preset_min_t),
		.preset_hr_u(4'd0),  
		.preset_hr_t(2'd0),

		.hund_out(hund), 
		.tenth_out(tenth),
		.sec_u_out(sec_u), 
		.sec_t_out(sec_t),
		.min_u_out(min_u), 
		.min_t_out(min_t),
		.hr_u_out(hr_u),   
		.hr_t_out(hr_t),
		.time_zero(time_zero)
	);

	// display window
	wire [3:0] digit3, digit2, digit1, digit0;
	wire       blank3, blank2, blank1, blank0;

	display_window window_unit (
		.hund_in(hund), 
		.tenth_in(tenth),
		.sec_u_in(sec_u), 
		.sec_t_in(sec_t),
		.min_u_in(min_u), 
		.min_t_in(min_t),
		.hr_u_in(hr_u),   
		.hr_t_in(hr_t),
		.digit3(digit3), 
		.digit2(digit2), 
		.digit1(digit1), 
		.digit0(digit0),
		.blank3(blank3), 
		.blank2(blank2), 
		.blank1(blank1), 
		.blank0(blank0)
	);

	hex7seg disp0 (
		.value(digit0), 
		.blank(blank0), 
		.seg(HEX0)
	);
	
	hex7seg disp1 (
		.value(digit1), 
		.blank(blank1), 
		.seg(HEX1)
	);
	
	hex7seg disp2 (
		.value(digit2), 
		.blank(blank2), 
		.seg(HEX2)
	);
	
	hex7seg disp3 (
		.value(digit3), 
		.blank(blank3), 
		.seg(HEX3)
	);

	// mode indicator on the two free displays
	assign HEX5 = count_down ? SEG_T : SEG_C;
	assign HEX4 = fast       ? SEG_F : SEG_OFF;

	// leds
	assign LEDR = {10{leds_on}};

endmodule
