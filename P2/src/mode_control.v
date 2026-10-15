//=============================================================
// mode_control
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/10/2026
//-------------------------------------------------------------
// Turns the push buttons into the control signals of the stopwatch_timer.
//
// Buttons are toggles: each press flips a state, so nothing has to be held down
// A rising edge detector makes sure one press counts once, even with the clock at 50 MHz
//
// In timer mode the switches are loaded continuously while the timer is being programmed, so the display shows the value as it's set
// Loading stops at the first start, so pausing in the middle of a countdown doesn't reload the preset
//
// Ports:
//   key        : push buttons, active low
//                key[0] start/pause  
//                key[1] reset
//                key[2] mode         
//                key[3] speed
//   time_zero  : the whole count is at zero
//   chain_rst  : clears the count
//   run        : lets the count advance
//   count_down : 0 stopwatch, 1 timer
//   fast       : runs the count 100 times faster
//   load       : copies the switches into the count
//   leds_on    : drives the leds, blinks when the timer ends
//=============================================================

module mode_control #(
	parameter BLINK_BIT = 23 // bit of the free counter used to blink
) (
	input  wire       clk,
	input  wire [3:0] key,
	input  wire       time_zero,
	output wire       chain_rst,
	output wire       run,
	output wire       count_down,
	output reg        fast,
	output wire       load,
	output wire       leds_on
);

	// buttons are active low, flip them so 1 means pressed
	wire [3:0] key_now = ~key;

	// previous value, to catch the moment a button goes down
	reg [3:0] key_prev;
	always @(posedge clk) 
		key_prev <= key_now;

	// high for a single cycle on each press
	wire [3:0] pressed = key_now & ~key_prev;

	wire start_pressed = pressed[0];
	wire reset_held    = key_now[1]; // reset acts while held, no toggle
	wire mode_pressed  = pressed[2];
	wire speed_pressed = pressed[3];

	reg timer_mode; // 0 stopwatch, 1 timer
	reg running;    // count is advancing
	reg setting;    // timer being programmed, before its first start

	// reset clears the count, changing mode also starts fresh
	assign chain_rst  = reset_held | mode_pressed;
	assign count_down = timer_mode;

	// the timer finished: timer mode, already started, count at zero
	wire timer_done = timer_mode & ~setting & time_zero;

	// mode and speed flip on each press, and survive a reset
	always @(posedge clk) 
		if (mode_pressed)  
			timer_mode <= ~timer_mode;
	always @(posedge clk) 
		if (speed_pressed) 
			fast <= ~fast;

	// start/pause flips, but stops by itself when the timer ends
	always @(posedge clk) begin
		if (chain_rst)          
			running <= 1'b0;
		else if (timer_done)    
			running <= 1'b0;
		else if (start_pressed) 
			running <= ~running;
	end

	// programming window: open after a reset, closed by the first start
	always @(posedge clk) begin
		if (chain_rst)          
			setting <= 1'b1;
		else if (start_pressed) 
			setting <= 1'b0;
	end

	assign run  = running & ~timer_done;
	assign load = timer_mode & setting;

	// free running counter, its top bit flips about three times a second
	reg [23:0] blink_count;
	always @(posedge clk) 
		blink_count <= blink_count + 1'b1;

	assign leds_on = timer_done & blink_count[BLINK_BIT];

	// power up values: stopwatch mode, stopped, normal speed
	initial begin
		key_prev    = 4'b0000;
		timer_mode  = 1'b0;
		running     = 1'b0;
		setting     = 1'b1;
		fast        = 1'b0;
		blink_count = 24'd0;
	end

endmodule
