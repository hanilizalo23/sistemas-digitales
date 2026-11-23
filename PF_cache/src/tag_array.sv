`timescale 1ns/1ps

//=============================================================
// tag_array
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// Valid bit, dirty bit and tag of every way of every set
// Two read ports, each one gives all the ways of one set at once: port A for the requests of the CPU, port B for snooping (what another cache asks on the bus)
// One write port, which can also clear the valid bit (invalidate)
//=============================================================

module tag_array #(
	parameter WAYS  = 4, // ways per set
	parameter SETS  = 8, // number of sets
	parameter TAG_W = 20 // bits of a tag
) (
	input  logic                        clk,
	input  logic                        rst,       // clears valid and dirty bits
	// read port A: the request
	input  logic [$clog2(SETS)-1:0]     index,     // set to look at
	output logic [WAYS-1:0]             valid_set, // valid bit of each way
	output logic [WAYS-1:0]             dirty_set, // dirty bit of each way
	output logic [WAYS-1:0][TAG_W-1:0]  tag_set,   // tag of each way
	// read port B: snooping
	input  logic [$clog2(SETS)-1:0]     snoop_index,
	output logic [WAYS-1:0]             snoop_valid_set,
	output logic [WAYS-1:0]             snoop_dirty_set,
	output logic [WAYS-1:0][TAG_W-1:0]  snoop_tag_set,
	// write port
	input  logic                        we,        // write one way
	input  logic [$clog2(SETS)-1:0]     w_index,   // in which set
	input  logic [$clog2(WAYS)-1:0]     w_way,     // which way
	input  logic                        w_valid,   // its new valid bit (0 invalidates)
	input  logic                        w_dirty,   // its new dirty bit
	input  logic [TAG_W-1:0]            w_tag      // its new tag
);

	// one valid bit and one dirty bit per line, as [set][way]
	logic [SETS-1:0][WAYS-1:0] valid;
	logic [SETS-1:0][WAYS-1:0] dirty;

	// one tag per line, as tags[set][way]
	logic [TAG_W-1:0]          tags [SETS][WAYS];

	// read: no clock, a whole set comes out of each port
	always_comb begin
		valid_set       = valid[index];
		dirty_set       = dirty[index];
		snoop_valid_set = valid[snoop_index];
		snoop_dirty_set = dirty[snoop_index];
		for (int w = 0; w < WAYS; w++) begin
			tag_set[w]       = tags[index][w];
			snoop_tag_set[w] = tags[snoop_index][w];
		end
	end

	// write: one way per clock
	always_ff @(posedge clk) begin
		if (rst) begin
			valid <= '0; // empty cache after reset
			dirty <= '0; // nothing to write back
		end
		else if (we) begin
			valid[w_index][w_way] <= w_valid; // 1 for a new line, 0 to invalidate
			dirty[w_index][w_way] <= w_dirty; // 1 on a write hit, else 0
			tags[w_index][w_way]  <= w_tag;   // which memory line it holds
		end
	end

	// tags have no reset: while valid is 0 their value doesn't matter

endmodule
