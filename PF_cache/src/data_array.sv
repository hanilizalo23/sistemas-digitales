`timescale 1ns/1ps

//=============================================================
// data_array
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// Data lines of every way of every set
// Each line has WORDS words
// Reading gives all the lines of one set at once, writing changes a whole line (from memory) or one word of it (a write hit)
//=============================================================

module data_array #(
	parameter WAYS   = 4,   // ways per set
	parameter SETS   = 8,   // number of sets
	parameter WORD_W = 16,  // bits of a word
	parameter WORDS  = 4    // words per line
) (
	input  logic                                   clk,
	input  logic [$clog2(SETS)-1:0]                index,    // set to look at
	output logic [WAYS-1:0][WORDS-1:0][WORD_W-1:0] line_set, // line of each way
	input  logic                                   line_we,  // write a whole line
	input  logic                                   word_we,  // write one word
	input  logic [$clog2(WAYS)-1:0]                w_way,    // which way
	input  logic [WORDS-1:0][WORD_W-1:0]           w_line,   // line from memory
	input  logic [$clog2(WORDS)-1:0]               w_offset, // which word of the line
	input  logic [WORD_W-1:0]                      w_word    // word to write
);

	// one line per [set][way], each line is WORDS words
	logic [WORDS-1:0][WORD_W-1:0] lines [SETS][WAYS];

	// read: no clock, every line of the set comes out at once
	always_comb begin
		for (int w = 0; w < WAYS; w++)
			line_set[w] = lines[index][w]; // line of each way of this set
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
