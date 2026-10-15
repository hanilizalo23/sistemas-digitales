//=============================================================
// display_window
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/10/2026
//-------------------------------------------------------------
// Decides which four digits reach the displays, and which of them stay blank
//
// The window slides as the count grows: hundredths and tenths at first, then seconds, then minutes, then hours
// Only two adjacent fields are ever shown, so the eight digits of the full count fit in four displays
// Leading digits stay blank until the count reaches them, so the display starts with a single digit and fills up
//
// Ports:
//   *_in      : the eight digits of the count
//   digit3..0 : the four values sent to the displays
//   blank3..0 : 1 keeps that display off
//=============================================================

module display_window (
	input  wire [3:0] hund_in,
	input  wire [3:0] tenth_in,
	input  wire [3:0] sec_u_in,
	input  wire [2:0] sec_t_in,
	input  wire [3:0] min_u_in,
	input  wire [2:0] min_t_in,
	input  wire [3:0] hr_u_in,
	input  wire [1:0] hr_t_in,

	output reg  [3:0] digit3,
	output reg  [3:0] digit2,
	output reg  [3:0] digit1,
	output reg  [3:0] digit0,

	output reg        blank3, // left
	output reg        blank2,
	output reg        blank1,
	output reg        blank0  // right
);

	// which fields the count has reached so far
	wire any_hours   = (hr_t_in  != 2'd0) || (hr_u_in  != 4'd0);
	wire any_minutes = (min_t_in != 3'd0) || (min_u_in != 4'd0);
	wire any_seconds = (sec_t_in != 3'd0) || (sec_u_in != 4'd0);
	wire any_tenths  = (tenth_in != 4'd0);

	always @(*) begin
		// default: everything off
		digit3 = 4'd0;  digit2 = 4'd0;  digit1 = 4'd0;  digit0 = 4'd0;
		blank3 = 1'b1;  blank2 = 1'b1;  blank1 = 1'b1;  blank0 = 1'b1;

		if (any_hours) begin
			// HH:MM
			digit3 = {2'd0, hr_t_in};  blank3 = (hr_t_in == 2'd0);  // hour tens, hidden while zero
			digit2 = hr_u_in;          blank2 = 1'b0;               // hour units, always on in this window
			digit1 = {1'b0, min_t_in}; blank1 = 1'b0;               // minute tens, zero is meaningful here
			digit0 = min_u_in;         blank0 = 1'b0;               // minute units, always on
		end
		else if (any_minutes) begin
			// MM:SS
			digit3 = {1'b0, min_t_in}; blank3 = (min_t_in == 3'd0); // minute tens, hidden while zero
			digit2 = min_u_in;         blank2 = 1'b0;               // minute units, always on in this window
			digit1 = {1'b0, sec_t_in}; blank1 = 1'b0;               // second tens, zero is meaningful here
			digit0 = sec_u_in;         blank0 = 1'b0;               // second units, always on
		end
		else begin
			// SS.cc
			digit3 = {1'b0, sec_t_in}; blank3 = (sec_t_in == 3'd0);         // second tens, hidden while zero
			digit2 = sec_u_in;         blank2 = ~any_seconds;               // second units, hidden until a second passes
			digit1 = tenth_in;         blank1 = ~any_seconds & ~any_tenths; // tenths, shown once seconds exist even if zero
			digit0 = hund_in;          blank0 = 1'b0;                       // hundredths, always on
		end
	end

endmodule