`timescale 1ns/1ps

//=============================================================
// hit_detect
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//
// This is the lookup of the cache: the set already chose which tags to look at, and this module says if the line is there and in which way
// It hasn't clock, so the whole lookup fits in the COMPARE state
//=============================================================

module hit_detect #(
	parameter WAYS  = 4, // ways per set
	parameter TAG_W = 20 // bits of a tag
) (
	input  logic [WAYS-1:0]             valid_set, // valid bit of each way
	input  logic [WAYS-1:0][TAG_W-1:0]  tag_set,   // tag of each way
	input  logic [TAG_W-1:0]            tag,       // tag of the request
	output logic                        hit,       // some way matched
	output logic [$clog2(WAYS)-1:0]     hit_way    // which one
);

	localparam WAY_W = $clog2(WAYS); // bits to number a way

	logic [WAYS-1:0] match; // one bit per way: this way matched

	always_comb begin
		hit_way = '0; // default if nothing matches
		for (int w = 0; w < WAYS; w++) begin
			// one comparator per way, all working in parallel
			match[w] = valid_set[w] && (tag_set[w] == tag);
			if (match[w])
				hit_way = WAY_W'(w); // number of the way that matched
		end
	end

	assign hit = |match; // hit if any way matched

	// at most one way can match: a line is never in a set twice

endmodule
