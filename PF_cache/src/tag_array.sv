`timescale 1ns/1ps

//=============================================================
// tag_array
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// Valid bit, dirty bit and tag of every way of every set
// Reading gives all the ways of one set at once, writing changes one way per clock
//=============================================================

module tag_array #(
	parameter WAYS  = 4, // ways per set
	parameter SETS  = 8, // number of sets
	parameter TAG_W = 20 // bits of a tag
) (
	input  logic                        clk,
	input  logic                        rst,       // clears valid and dirty bits
	input  logic [$clog2(SETS)-1:0]     index,     // set to look at
	output logic [WAYS-1:0]             valid_set, // valid bit of each way
	output logic [WAYS-1:0]             dirty_set, // dirty bit of each way
	output logic [WAYS-1:0][TAG_W-1:0]  tag_set,   // tag of each way
	input  logic                        we,        // write one way
	input  logic [$clog2(WAYS)-1:0]     w_way,     // which way
	input  logic                        w_dirty,   // its new dirty bit
	input  logic [TAG_W-1:0]            w_tag      // its new tag
);

	// one valid bit and one dirty bit per line, as [set][way]
	logic [SETS-1:0][WAYS-1:0] valid;
	logic [SETS-1:0][WAYS-1:0] dirty;

	// one tag per line, as tags[set][way]
	logic [TAG_W-1:0] tags [SETS][WAYS];

	// read: no clock, the whole set comes out at once
	always_comb begin
		valid_set = valid[index];        // valid bits of this set
		dirty_set = dirty[index];        // dirty bits of this set
		for (int w = 0; w < WAYS; w++)
			tag_set[w] = tags[index][w]; // tag of each way of this set
	end

	// write: one way per clock
	always_ff @(posedge clk) begin
		if (rst) begin
			valid <= '0;                    // empty cache after reset
			dirty <= '0;                    // nothing to write back
		end
		else if (we) begin
			valid[index][w_way] <= 1'b1;    // a written way is always valid
			dirty[index][w_way] <= w_dirty; // 1 on a write hit, 0 when a line arrives
		  //dirty[index][w_way] <= 1'b0;    // bug on purpose, to test the checks --> a write hit never marks the line dirty, so its data is lost when the line is replaced (caught by write_makes_dirty in cache_sva)
			tags[index][w_way]  <= w_tag;   // which memory line it holds now
		end
	end

	// tags have no reset: while valid is 0 their value doesn't matter

endmodule
