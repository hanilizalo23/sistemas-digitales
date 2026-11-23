`timescale 1ns/1ps

//=============================================================
// data_array
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// Data lines of every way of every set
// Each line has WORDS words
// Two read ports, each one gives all the lines of one set at once: port A for the requests of the CPU, port B for snooping (to hand a modified line back to memory)
// Writing changes a whole line (from memory) or one word (a write hit)
//=============================================================

module data_array #(
	parameter WAYS   = 4,  // ways per set
	parameter SETS   = 8,  // number of sets
	parameter WORD_W = 16, // bits of a word
	parameter WORDS  = 4   // words per line
) (
	input  logic                                   clk,
	// read port A: the request
	input  logic [$clog2(SETS)-1:0]                index,    // set to look at
	output logic [WAYS-1:0][WORDS-1:0][WORD_W-1:0] line_set, // line of each way
	// read port B: snooping
	input  logic [$clog2(SETS)-1:0]                snoop_index,
	output logic [WAYS-1:0][WORDS-1:0][WORD_W-1:0] snoop_line_set,
	// write port, always in the set of the request
	input  logic                                   line_we,  // write a whole line
	input  logic                                   word_we,  // write one word
	input  logic [$clog2(WAYS)-1:0]                w_way,    // which way
	input  logic [WORDS-1:0][WORD_W-1:0]           w_line,   // line from memory
	input  logic [$clog2(WORDS)-1:0]               w_offset, // which word of the line
	input  logic [WORD_W-1:0]                      w_word    // word to write
);

	// one line per [set][way], each line is WORDS words
	logic [WORDS-1:0][WORD_W-1:0] lines [SETS][WAYS];

	// read: no clock, every line of a set comes out of each port
	always_comb begin
		for (int w = 0; w < WAYS; w++) begin
			line_set[w]       = lines[index][w];
			snoop_line_set[w] = lines[snoop_index][w];
		end
	end

	// write: one way per clock (both writes never happen together)
	always_ff @(posedge clk) begin
		if (line_we)
			lines[index][w_way] <= w_line;           // whole line brought from memory
		else if (word_we)
			lines[index][w_way][w_offset] <= w_word; // only the written word changes
	end

	// no reset: data only counts once its tag is valid

endmodule
