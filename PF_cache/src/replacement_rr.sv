`timescale 1ns/1ps
//=============================================================
// replacement_rr
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// Round Robin: each set has a pointer to its next victim, and it moves to the next way every time a line comes into the set
// WAYS has to be a power of two so the pointer wraps by itself
// After reset all pointers are 0, so a set fills its ways in order before replacing anything
//=============================================================

module replacement_rr #(
	parameter WAYS = 4, // ways per set
	parameter SETS = 8  // number of sets
) (
	input  logic                     clk,
	input  logic                     rst,       // all pointers back to way 0
	input  logic [$clog2(SETS)-1:0]  index,     // set being accessed
	input  logic                     advance,   // a line came into the set
	output logic [$clog2(WAYS)-1:0]  victim_way // way to replace next
);

	logic [SETS-1:0][$clog2(WAYS)-1:0] ptr; // next victim of each set

	assign victim_way = ptr[index]; // pointer of the current set

	always_ff @(posedge clk) begin
		if (rst)
			ptr <= '0; // every set starts at way 0
		else if (advance)
			ptr[index] <= ptr[index] + 1'b1; // next way, wraps after the last one
	end

	// hits don't move the pointer (that is the difference with LRU)

endmodule
