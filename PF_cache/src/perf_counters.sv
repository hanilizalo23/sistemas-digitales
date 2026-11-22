`timescale 1ns/1ps

//=============================================================
// perf_counters
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/21/2026
//-------------------------------------------------------------
// Counts the event pulses of the cache: hits, misses and evictions
//
// clear sets them back to 0 (at the start of a pattern)
//=============================================================

module perf_counters #(
	parameter CNT_W = 16 // bits of each counter
) (
	input  logic             clk,
	input  logic             rst,
	input  logic             clear,  // back to 0
	input  logic             ev_hit, // one-clock pulses from the cache
	input  logic             ev_miss,
	input  logic             ev_evict,
	output logic [CNT_W-1:0] hits,
	output logic [CNT_W-1:0] misses,
	output logic [CNT_W-1:0] evictions
);

	always_ff @(posedge clk) begin
		if (rst || clear) begin
			hits      <= '0;
			misses    <= '0;
			evictions <= '0;
		end
		else begin
			if (ev_hit)   hits      <= hits + 1'b1;
			if (ev_miss)  misses    <= misses + 1'b1;
			if (ev_evict) evictions <= evictions + 1'b1;
		end
	end

endmodule
