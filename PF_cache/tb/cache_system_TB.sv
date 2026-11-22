`timescale 1ns/1ps

//=============================================================
// cache_system_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/21/2026
//-------------------------------------------------------------
// Runs the three patterns of the generator, one after the other, starting each one from an empty cache, and prints the hit rate of each
// Change WAYS to 2, 4 or 8 to compare
//
// Expected:
//   LOOP     (384 accesses)  2 ways: 75%   4 and 8 ways: 93.75%
//   STREAM   (256 accesses)  75% with any number of ways
//   CONFLICT (48 accesses)   2 ways: 0%    4 and 8 ways: 93.75%
//=============================================================

module cache_system_TB;

	parameter WAYS = 2; // change to 4 or 8 to compare

	logic        clk, rst, start, done;
	logic [1:0]  pattern_sel;
	logic [15:0] hits, misses, evictions;

	// between the system and the memory model
	logic             mem_valid, mem_we, mem_ready;
	logic [22:0]      mem_addr;
	logic [3:0][15:0] mem_wdata, mem_rdata;

	cache_system #(.WAYS(WAYS)) UUT (
		.clk(clk), 
		.rst(rst), 
		.start(start), 
		.pattern_sel(pattern_sel), 
		.done(done),
		.hits(hits), 
		.misses(misses), 
		.evictions(evictions),
		.mem_valid(mem_valid), 
		.mem_we(mem_we), 
		.mem_addr(mem_addr),
		.mem_wdata(mem_wdata), 
		.mem_ready(mem_ready), 
		.mem_rdata(mem_rdata)
	);

	mem_model #(.LATENCY(4)) memory (
		.clk(clk), 
		.rst(rst),
		.mem_valid(mem_valid), 
		.mem_we(mem_we), 
		.mem_addr(mem_addr),
		.mem_wdata(mem_wdata), 
		.mem_ready(mem_ready), 
		.mem_rdata(mem_rdata)
	);

	// the same checks as in cache_TB, on the cache inside the system
	bind cache cache_sva #(.WAYS(WAYS), .SETS(SETS)) sva (
		.clk(clk), 
		.rst(rst),
		.req_valid(req_valid), 
		.resp_ready(resp_ready),
		.mem_valid(mem_valid), 
		.mem_we(mem_we), 
		.mem_ready(mem_ready), 
		.mem_addr(mem_addr),
		.victim_valid(victim_valid), 
		.victim_dirty(victim_dirty),
		.match(hit_check.match),
		.valid_all(tag_store.valid), 
		.dirty_all(tag_store.dirty),
		.word_we(word_we), 
		.req_index(req_index), 
		.hit_way(hit_way)
	);

	always #10 clk = ~clk; // 50 MHz

	// run one pattern from an empty cache and print its results
	task automatic run_pattern(input logic [1:0] sel, input string name);
		int reads0, writes0, cycles;
		real rate;
		// empty the cache
		@(negedge clk) rst = 1;
		repeat (2) @(negedge clk);
		rst = 0;
		reads0  = memory.line_reads; // memory totals before this pattern
		writes0 = memory.line_writes;
		// start pulse
		pattern_sel = sel;
		start = 1;
		@(negedge clk) start = 0;
		cycles = 0;
		while (!done) begin          // wait for the pattern to finish
			@(negedge clk);
			cycles++;
		end
		rate = 100.0 * real'(hits) / real'(hits + misses);
		$display("%-8s WAYS=%0d: %4d accesses, hits %4d, misses %3d, evictions %3d, hit rate %6.2f%%",
		         name, WAYS, hits + misses, hits, misses, evictions, rate);
		$display("         memory: %0d lines read, %0d written, %0d cycles",
		         memory.line_reads - reads0, memory.line_writes - writes0, cycles);
	endtask

	initial begin
		clk = 0; rst = 1; start = 0; pattern_sel = 2'd0;
		run_pattern(2'd0, "LOOP");
		run_pattern(2'd1, "STREAM");
		run_pattern(2'd2, "CONFLICT");
		$display("check errors = %0d", UUT.cache_core.sva.errors);
		$stop;
	end

endmodule
