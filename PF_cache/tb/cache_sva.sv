`timescale 1ns/1ps

//=============================================================
// cache_sva
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// Checks for the cache
// They're attached to the cache with bind (see cache_TB), so the design files stay untouched
//
// The rules are written twice:
//   - as plain checks (if + $error), which any simulator runs
//   - as SVAs at the end, which Questa runs and a formal tool can use
// When a rule breaks, both versions report it
//=============================================================

module cache_sva #(
	parameter WAYS        = 4, // ways per set
	parameter SETS        = 8, // number of sets
	parameter LINE_ADDR_W = 23 // bits of a line address
) (
	input logic                       clk,
	input logic                       rst,
	input logic                       req_valid,    // request side
	input logic                       resp_ready,
	input logic                       mem_valid,    // memory side
	input logic                       mem_we,
	input logic                       mem_ready,
	input logic [LINE_ADDR_W-1:0]     mem_addr,
	input logic                       victim_valid, // victim chosen by round robin
	input logic                       victim_dirty,
	input logic [WAYS-1:0]            match,        // lookup: which ways matched
	input logic [SETS-1:0][WAYS-1:0]  valid_all,    // every valid bit of the cache
	input logic [SETS-1:0][WAYS-1:0]  dirty_all,    // every dirty bit of the cache
	input logic                       word_we,      // write hit
	input logic [$clog2(SETS)-1:0]    req_index,    // set of the request
	input logic [$clog2(WAYS)-1:0]    hit_way       // way of the hit
);

	int errors = 0; // how many checks failed

	// what some signals were one clock ago (for rules 3 and 5)
	logic                      mem_wait_q;  // was waiting on memory
	logic                      mem_we_q;
	logic [LINE_ADDR_W-1:0]    mem_addr_q;
	logic                      word_we_q;   // was a write hit
	logic [$clog2(SETS)-1:0]   req_index_q;
	logic [$clog2(WAYS)-1:0]   hit_way_q;

	always_ff @(posedge clk) begin
		mem_wait_q  <= mem_valid && !mem_ready;
		mem_we_q    <= mem_we;
		mem_addr_q  <= mem_addr;
		word_we_q   <= word_we;
		req_index_q <= req_index;
		hit_way_q   <= hit_way;
	end

	// the checks, on every rising edge except during reset
	always @(posedge clk) begin
		if (!rst) begin

			// a line is never twice in the same set: at most one way matches (a value with at most one 1 gives 0 when ANDed with itself minus 1)
			if (req_valid && ((match & (match - 1'b1)) != '0)) begin
				$error("one_copy: the line is in more than one way of set %0d", req_index);
				errors++;
			end

			// a dirty line is always valid
			if ((dirty_all & ~valid_all) != '0) begin
				$error("dirty_is_valid: a dirty bit is set on an empty way");
				errors++;
			end

			// memory handshake: the request doesn't change until mem_ready
			if (mem_wait_q && !(mem_valid && mem_we == mem_we_q && mem_addr == mem_addr_q)) begin
				$error("mem_hold: the memory request changed before mem_ready");
				errors++;
			end

			// only a valid and dirty victim is written back
			if (mem_valid && mem_we && !(victim_valid && victim_dirty)) begin
				$error("wb_only_dirty: write-back of a victim that is not dirty");
				errors++;
			end

			// after a write hit, that line is dirty
			if (word_we_q && !dirty_all[req_index_q][hit_way_q]) begin
				$error("write_makes_dirty: set %0d way %0d is not dirty after a write",
				       req_index_q, hit_way_q);
				errors++;
			end

			// the cache only answers while there is a request
			if (resp_ready && !req_valid) begin
				$error("resp_needs_req: resp_ready without a request");
				errors++;
			end
		end
	end

	// summary when the simulation ends
	final $display("cache_sva: %0d check errors", errors);


	// ========= The same rules as SystemVerilog Assertions (Formal Verification SVAs) =========

	// a line is never twice in the same set: at most one way matches
	a_one_copy: assert property (@(posedge clk) disable iff (rst)
		req_valid |-> $onehot0(match));

	// a dirty line is always valid (no dirty bit without a line)
	a_dirty_is_valid: assert property (@(posedge clk) disable iff (rst)
		(dirty_all & ~valid_all) == '0);

	// memory handshake: the request doesn't change until mem_ready
	a_mem_hold: assert property (@(posedge clk) disable iff (rst)
		mem_valid && !mem_ready |=> mem_valid && $stable(mem_we) && $stable(mem_addr));

	// only a valid and dirty victim is written back
	a_wb_only_dirty: assert property (@(posedge clk) disable iff (rst)
		mem_valid && mem_we |-> victim_valid && victim_dirty);

	// after a write hit, that line is dirty
	a_write_makes_dirty: assert property (@(posedge clk) disable iff (rst)
		word_we |=> dirty_all[$past(req_index)][$past(hit_way)]);

	// the cache only answers while there is a request
	a_resp_needs_req: assert property (@(posedge clk) disable iff (rst)
		resp_ready |-> req_valid);

	// coverage: the test did reach a write-back
	c_write_back: cover property (@(posedge clk) disable iff (rst)
		mem_valid && mem_we);

endmodule
