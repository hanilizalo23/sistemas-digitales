`timescale 1ns/1ps

//=============================================================
// cache_system
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/21/2026
//-------------------------------------------------------------
// Top level of the project: the access generator plays the CPU, the cache answers, and the counters measure
// The memory side comes out as ports, so what sits behind the cache can change (a model in simulation, the SDRAM, or a bus)
//=============================================================

module cache_system #(
	parameter WAYS   = 4,  // ways per set (2, 4 or 8)
	parameter SETS   = 8,  // number of sets
	parameter WORD_W = 16, // bits of a word
	parameter WORDS  = 4,  // words per line
	parameter ADDR_W = 25, // bits of a word address
	parameter CNT_W  = 16  // bits of each counter
) (
	input  logic                          clk,
	input  logic                          rst,
	input  logic                          start,       // begin a pattern
	input  logic [1:0]                    pattern_sel, // 0 loop, 1 stream, 2 conflict
	output logic                          done,        // pattern finished
	output logic [CNT_W-1:0]              hits,        // results
	output logic [CNT_W-1:0]              misses,
	output logic [CNT_W-1:0]              evictions,
	// memory side, whole lines
	output logic                            mem_valid,
	output logic                            mem_we,
	output logic [ADDR_W-$clog2(WORDS)-1:0] mem_addr,
	output logic [WORDS-1:0][WORD_W-1:0]    mem_wdata,
	input  logic                            mem_ready,
	input  logic [WORDS-1:0][WORD_W-1:0]    mem_rdata
);

	// between the generator and the cache
	logic              req_valid, req_we, resp_ready;
	logic [ADDR_W-1:0] req_addr;
	logic [WORD_W-1:0] req_wdata;
	logic [WORD_W-1:0] resp_rdata; // not used --> the data is checked in cache_TB

	// between the cache and the counters
	logic ev_hit, ev_miss, ev_evict;

	access_generator #(.ADDR_W(ADDR_W), .WORD_W(WORD_W), .SETS(SETS), .WORDS(WORDS)) generator (
		.clk(clk), 
		.rst(rst), 
		.start(start), 
		.pattern_sel(pattern_sel),
		.req_valid(req_valid), 
		.req_we(req_we), 
		.req_addr(req_addr), 
		.req_wdata(req_wdata),
		.resp_ready(resp_ready), 
		.done(done)
	);

	cache #(.WAYS(WAYS), .SETS(SETS), .WORD_W(WORD_W), .WORDS(WORDS), .ADDR_W(ADDR_W)) cache_core (
		.clk(clk), 
		.rst(rst),
		.req_valid(req_valid), 
		.req_we(req_we), 
		.req_addr(req_addr), 
		.req_wdata(req_wdata),
		.resp_ready(resp_ready), 
		.resp_rdata(resp_rdata),
		.mem_valid(mem_valid), 
		.mem_we(mem_we), 
		.mem_addr(mem_addr),
		.mem_wdata(mem_wdata), 
		.mem_ready(mem_ready), 
		.mem_rdata(mem_rdata),
		.ev_hit(ev_hit), 
		.ev_miss(ev_miss), 
		.ev_evict(ev_evict)
	);

	// counters start from 0 with each new pattern
	perf_counters #(.CNT_W(CNT_W)) counters (
		.clk(clk), 
		.rst(rst), 
		.clear(start),
		.ev_hit(ev_hit), 
		.ev_miss(ev_miss), 
		.ev_evict(ev_evict),
		.hits(hits), 
		.misses(misses), 
		.evictions(evictions)
	);

endmodule
