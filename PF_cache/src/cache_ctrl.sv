`timescale 1ns/1ps

//=============================================================
// cache_ctrl
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// FSM of the cache (the 4-state controller from Patterson and Hennessy, but for N ways)
//
//   IDLE       waits for a request
//   COMPARE    checks the tags, a hit ends the access, a miss goes to memory
//   WRITE_BACK sends the dirty victim line to memory
//   ALLOCATE   brings the new line, then back to COMPARE, where it's now a hit
//
// Memory handshake: mem_valid stays high until mem_ready
//=============================================================


module cache_ctrl (
	input  logic clk,
	input  logic rst,
	input  logic req_valid,    // there is a request
	input  logic req_we,       // it's a write
	input  logic hit,          // the lookup found the line
	input  logic victim_valid, // the victim way holds a line
	input  logic victim_dirty, // and that line was written
	input  logic mem_ready,    // memory finished
	output logic mem_valid,    // request to memory
	output logic mem_we,       // 1: write-back, 0: read a line
	output logic resp_ready,   // access finished
	output logic word_we,      // write hit: write the word
	output logic fill,         // line arrived: store it
	output logic ev_hit,       // one-clock pulses for the counters
	output logic ev_miss,
	output logic ev_evict
);

	// the four states
	typedef enum logic [1:0] {IDLE, COMPARE, WRITE_BACK, ALLOCATE} state_t;

	state_t state, next_state;
	logic   refilled; // this access already brought its line

	// state register
	always_ff @(posedge clk) begin
		if (rst)
			state <= IDLE;
		else
			state <= next_state;
	end

	// next state
	always_comb begin
		next_state = state; // stay, unless something below
		case (state)
			IDLE:       if (req_valid) next_state = COMPARE;   // new request
			COMPARE:    if (hit)
			                next_state = IDLE;                 // done
			            else if (victim_valid && victim_dirty) 
			                next_state = WRITE_BACK;           // save the victim first
			            else
			                next_state = ALLOCATE;             // victim can be overwritten
			WRITE_BACK: if (mem_ready) next_state = ALLOCATE;  // victim saved
			ALLOCATE:   if (mem_ready) next_state = COMPARE;   // new line is in
		endcase
	end

	// after a refill the second compare is a hit, but it's not counted as one: that access was a miss
	always_ff @(posedge clk) begin
		if (rst)
			refilled <= 1'b0;
		else if (fill)
			refilled <= 1'b1;   // the line was just brought
		else if (state == IDLE)
			refilled <= 1'b0;   // ready for the next access
	end

	// outputs
	assign resp_ready = (state == COMPARE) && hit;        // hit ends the access
	assign word_we    = resp_ready && req_we;             // and a write hit writes the word
	assign fill       = (state == ALLOCATE) && mem_ready; // the new line just arrived

	assign mem_valid  = (state == WRITE_BACK) || (state == ALLOCATE); // waiting on memory
	assign mem_we     = (state == WRITE_BACK);                        // only write-back writes

	assign ev_hit     = resp_ready && !refilled;    // hit on the first compare
	assign ev_miss    = (state == COMPARE) && !hit; // once per missed access
	assign ev_evict   = fill && victim_valid;       // a valid line got replaced

endmodule
