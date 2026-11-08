//=============================================================
// tx_fsm
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Control of the UART transmitter
// Each state is one part of the frame, and lasts one bit time (one baud_tick), except DATA, which lasts the 8 data bits
//
//   IDLE   -> line high, the data and its parity are loaded
//   START  -> line low, start bit
//   DATA   -> line follows the shift register, 8 bits
//   PARITY -> line carries the even parity bit
//   STOP   -> line high, stop bit
//
// Outputs:
//   idle   : high in IDLE, keeps the data loaded and the counters cleared until a transmission starts
//   shift  : moves the shift register to the next data bit
//   tx_sel : picks what the line carries (see the mux in uart_tx)
//=============================================================

module tx_fsm (
	input  wire       clk,
	input  wire       rst,
	input  wire       tx_send,   // start a transmission
	input  wire       baud_tick, // end of a bit time
	input  wire       bit_done,  // last data bit is ending
	output wire       idle,
	output wire       shift,
	output reg  [1:0] tx_sel
);

	localparam [2:0] S_IDLE   = 3'd0,
	                 S_START  = 3'd1,
	                 S_DATA   = 3'd2,
	                 S_PARITY = 3'd3,
	                 S_STOP   = 3'd4;

	// tx_sel values, matching the mux inputs in uart_tx
	localparam [1:0] SEL_ONE    = 2'd0,
	                 SEL_ZERO   = 2'd1,
	                 SEL_DATA   = 2'd2,
	                 SEL_PARITY = 2'd3;

	reg [2:0] state, next_state;

	// state register
	always @(posedge clk) begin
		if (rst)
			state <= S_IDLE;
		else
			state <= next_state;
	end

	// next state logic: every move happens at the end of a bit
	always @(*) begin
		next_state = state;
		case (state)
			S_IDLE:   if (tx_send)   next_state = S_START;
			S_START:  if (baud_tick) next_state = S_DATA;
			S_DATA:   if (bit_done)  next_state = S_PARITY;
			S_PARITY: if (baud_tick) next_state = S_STOP;
			S_STOP:   if (baud_tick) next_state = S_IDLE;
			default:                 next_state = S_IDLE;
		endcase
	end

	// output logic
	assign idle  = (state == S_IDLE);
	assign shift = (state == S_DATA) & baud_tick;

	always @(*) begin
		case (state)
			S_START:  tx_sel = SEL_ZERO;
			S_DATA:   tx_sel = SEL_DATA;
			S_PARITY: tx_sel = SEL_PARITY;
			default:  tx_sel = SEL_ONE; // IDLE and STOP
		endcase
	end

endmodule
