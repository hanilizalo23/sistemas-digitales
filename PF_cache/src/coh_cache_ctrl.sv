`timescale 1ns/1ps

//=============================================================
// coh_cache_ctrl
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/22/2026
//-------------------------------------------------------------
// FSM of the coherent cache (MSI)
// Same four states as cache_ctrl, but the memory side is now a shared bus:
//
//   IDLE       waits for a request
//   COMPARE    a read hit, or a write hit on a line we own (M), ends the access, a write hit on a shared line (S) has to ask the bus for ownership first, a miss goes to the bus
//   WRITE_BACK sends the dirty victim line to memory (BUS_WB)
//   ALLOCATE   reads the line from the bus: BUS_RD for a read, BUS_RDX for a write (read and invalidate the other copies), then back to COMPARE
//
// The bus request stays high until bus_done
//=============================================================

module coh_cache_ctrl (
	input  logic       clk,
	input  logic       rst,
	input  logic       req_valid,    // there's a request
	input  logic       req_we,       // it's a write
	input  logic       hit,          // the lookup found the line
	input  logic       hit_dirty,    // and we own it (M)
	input  logic       victim_valid, // the victim way holds a line
	input  logic       victim_dirty, // and that line was written
	input  logic       bus_done,     // the bus finished our request
	output logic       bus_req,      // request to the bus
	output logic [1:0] bus_cmd,      // BUS_RD, BUS_RDX or BUS_WB
	output logic       resp_ready,   // access finished
	output logic       word_we,      // write hit: write the word
	output logic       fill,         // line arrived: store it
	output logic       upgrade,      // this access is getting ownership of a line it has
	output logic       need_upgrade, // COMPARE found a write hit on a shared line
	output logic       in_compare,   // snooping waits while this is high
	output logic       ev_hit,       // one-clock pulses for the counters
	output logic       ev_miss,
	output logic       ev_upgrade,
	output logic       ev_evict
);

	// bus commands, the same values as in coh_bus
	localparam [1:0] BUS_RD = 2'd0, BUS_RDX = 2'd1, BUS_WB = 2'd2;

	// the four states, shown by name in the waves
	typedef enum logic [1:0] {IDLE, COMPARE, WRITE_BACK, ALLOCATE} state_t;

	state_t state, next_state;
	logic   refilled;   // this access already brought its line (and owns it if it's a write)
	logic   can_finish; // COMPARE can end the access now

	// a read hit is enough to finish, a write needs the line in M, or to have just brought it with BUS_RDX
	assign can_finish   = hit && (!req_we || hit_dirty || refilled);
	assign need_upgrade = (state == COMPARE) && hit && req_we && !hit_dirty && !refilled;

	// state register
	always_ff @(posedge clk) begin
		if (rst)
			state <= IDLE;
		else
			state <= next_state;
	end

	// next state
	always_comb begin
		next_state = state;
		case (state)
			IDLE:       if (req_valid) next_state = COMPARE;   // new request
			COMPARE:    if (can_finish)
			                next_state = IDLE;                 // done
			            else if (hit)
			                next_state = ALLOCATE;             // write on S: ask for ownership
			            else if (victim_valid && victim_dirty)
			                next_state = WRITE_BACK;           // miss: save the victim first
			            else
			                next_state = ALLOCATE;             // miss: victim can be overwritten
			WRITE_BACK: if (bus_done) next_state = ALLOCATE;   // victim saved
			ALLOCATE:   if (bus_done) next_state = COMPARE;    // line is in
		endcase
	end

	// remembers that the line came from the bus during this access
	always_ff @(posedge clk) begin
		if (rst)
			refilled <= 1'b0;
		else if (fill)
			refilled <= 1'b1;
		else if (state == IDLE)
			refilled <= 1'b0;
	end

	// remembers that this ALLOCATE is an upgrade (the line is already in the cache, in hit_way), not a miss
	always_ff @(posedge clk) begin
		if (rst)
			upgrade <= 1'b0;
		else if (state == COMPARE)
			upgrade <= need_upgrade;
	end

	// outputs
	assign resp_ready = (state == COMPARE) && can_finish;
	assign word_we    = resp_ready && req_we;
	assign fill       = (state == ALLOCATE) && bus_done;
	assign in_compare = (state == COMPARE);

	assign bus_req    = (state == WRITE_BACK) || (state == ALLOCATE);
	assign bus_cmd    = (state == WRITE_BACK) ? BUS_WB : (req_we ? BUS_RDX : BUS_RD);

	assign ev_hit     = resp_ready && !refilled;          // finished on the first compare
	assign ev_miss    = (state == COMPARE) && !hit;       // once per missed access
	assign ev_upgrade = need_upgrade;                     // write on a shared line
	assign ev_evict   = fill && !upgrade && victim_valid; // a valid line got replaced

endmodule
