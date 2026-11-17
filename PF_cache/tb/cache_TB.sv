`timescale 1ns/1ps

//=============================================================
// cache_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// Directed test of the cache with mem_model behind it
// Uses 2 ways so conflicts happen fast
// 0x00, 0x20, 0x40 and 0x60 all go to set 0 (tags 0 to 3)
//
//   1  read  0x00          miss, goes to way 0
//   2  read  0x01          hit (same line)
//   3  write 0x02 = BEEF   hit, the line gets dirty
//   4  read  0x02          hit, "BEEF"
//   5  read  0x20          miss, goes to way 1
//   6  read  0x40          miss, kicks out the dirty line of 0x00 (write-back first)
//   7  read  0x02          miss, kicks out 0x20 (clean), "BEEF" has to come back from memory
//   8  write 0x63 = 1234   write miss: bring the line, then write
//   9  read  0x63          hit, 1234
//  10  read  0x04          miss, set 1
//
// With 2 ways: 4 hits, 6 misses, 3 evictions, 6 lines read and 1 written by memory
//=============================================================

module cache_TB;

	parameter WAYS = 2; // change to 4 or 8 to compare

	// request side (the TB plays the CPU)
	logic        clk, rst;
	logic        req_valid, req_we;
	logic [24:0] req_addr;
	logic [15:0] req_wdata;
	logic        resp_ready;
	logic [15:0] resp_rdata;

	// between the cache and the memory model
	logic             mem_valid, mem_we, mem_ready;
	logic [22:0]      mem_addr;
	logic [3:0][15:0] mem_wdata, mem_rdata;

	// events and totals
	logic ev_hit, ev_miss, ev_evict;
	int   hits = 0, misses = 0, evictions = 0, wrong = 0, step = 0;

	cache #(.WAYS(WAYS)) UUT (
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

	// assertions, attached to the cache without touching its files
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

	// 20 ns period, 50 MHz
	always #10 clk = ~clk;

	// count the event pulses
	always @(posedge clk) begin
		if (ev_hit)   hits++;
		if (ev_miss)  misses++;
		if (ev_evict) evictions++;
	end

	// one access, holding the request until resp_ready (like a CPU)
	task automatic access(input logic we, input logic [24:0] addr,
	                      input logic [15:0] wdata, input logic [15:0] expected);
		logic [15:0] rdata;
		int          cycles = 0;
		step++;
		@(negedge clk); // change inputs away from the edge
		req_valid = 1; req_we = we; req_addr = addr; req_wdata = wdata;
		do begin
			@(negedge clk); // wait one clock at a time
			cycles++;
		end while (!resp_ready); // until the cache answers
		rdata = resp_rdata;      // keep the word read
		@(negedge clk);          // FSM already back in IDLE
		req_valid = 0; req_we = 0;

		if (we)
			$display("%2d  write %h = %h   %0d cycles", step, addr, wdata, cycles + 1);
		else begin
			$display("%2d  read  %h -> %h   %0d cycles%s", step, addr, rdata, cycles + 1,
			         (rdata == expected) ? "" : "   <-- WRONG");
			if (rdata != expected) wrong++;
		end
	endtask

	initial begin
		clk = 0; rst = 1; // start in reset
		req_valid = 0; req_we = 0; req_addr = '0; req_wdata = '0;
		repeat (2) @(negedge clk);
		rst = 0;

		//     we address data      expected
		access(0, 25'h00, 16'h0000, 16'h0000);
		access(0, 25'h01, 16'h0000, 16'h0001);
		access(1, 25'h02, 16'hBEEF, 16'h0000);
		access(0, 25'h02, 16'h0000, 16'hBEEF);
		access(0, 25'h20, 16'h0000, 16'h0020);
		access(0, 25'h40, 16'h0000, 16'h0040);
		access(0, 25'h02, 16'h0000, 16'hBEEF);
		access(1, 25'h63, 16'h1234, 16'h0000);
		access(0, 25'h63, 16'h0000, 16'h1234);
		access(0, 25'h04, 16'h0000, 16'h0004);

		repeat (2) @(negedge clk);
		$display("--------------------------------------------");
		$display("WAYS = %0d: hits = %0d, misses = %0d, evictions = %0d",
		         WAYS, hits, misses, evictions);
		$display("memory: %0d lines read, %0d lines written",
		         memory.line_reads, memory.line_writes);
		$display("wrong reads = %0d", wrong);
		$display("check errors = %0d", UUT.sva.errors); // from cache_sva
		$stop;
	end

endmodule
