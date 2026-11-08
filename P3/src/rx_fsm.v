//=============================================================
// rx_fsm
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Control of the UART receiver
// The baud counter ticks in the middle of each bit, so every decision samples the line far from the edges
//
//   IDLE  -> waits for the line to drop (start of a frame)
//   START -> at mid start bit, checks the line is still low, if not, it was a glitch and returns to IDLE
//   DATA  -> samples 9 bits: the 8 data bits and the parity
//   STOP  -> at mid stop bit, stores the received word
//
// Outputs:
//   idle  : high in IDLE; preloads the baud counter to half a bit and clears the bit counter
//   shift : stores the current bit into the shift register
//   store : copies the full word into the output register
//=============================================================

module rx_fsm (
	input  wire clk,
	input  wire rst,
	input  wire rx_sync,   // synchronized serial line
	input  wire baud_tick, // middle of a bit
	input  wire bit_done,  // last of the 9 bits sampled
	output wire idle,
	output wire shift,
	output wire store
);

	localparam [1:0] S_IDLE  = 2'd0,
	                 S_START = 2'd1,
	                 S_DATA  = 2'd2,
	                 S_STOP  = 2'd3;

	reg [1:0] state, next_state;

	// state register
	always @(posedge clk) begin
		if (rst)
			state <= S_IDLE;
		else
			state <= next_state;
	end

	// next state logic
	always @(*) begin
		next_state = state;
		case (state)
			S_IDLE:  if (!rx_sync)  next_state = S_START;
			S_START: if (baud_tick) next_state = rx_sync ? S_IDLE : S_DATA;
			S_DATA:  if (bit_done)  next_state = S_STOP;
			S_STOP:  if (baud_tick) next_state = S_IDLE;
			default:                next_state = S_IDLE;
		endcase
	end

	// output logic
	assign idle  = (state == S_IDLE);
	assign shift = (state == S_DATA) & baud_tick;
	assign store = (state == S_STOP) & baud_tick;

endmodule
