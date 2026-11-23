`timescale 1ns/1ps

//=============================================================
// coh_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/22/2026
//-------------------------------------------------------------
// Two CPUs, each with its coherent cache, sharing the memory through coh_bus
// Directed test of the MSI protocol, every word in memory starts holding its own address
//
//   1  CPU0 read  0x00          miss, CPU0 gets the line in S
//   2  CPU1 read  0x01          miss, both have it in S
//   3  CPU0 write 0x02 = AAAA   write on S: CPU0 takes ownership (M), CPU1 is invalidated
//   4  CPU1 read  0x02          miss: CPU0 hands the line to memory (flush) and goes to S, CPU1 reads AAAA
//   5  CPU1 write 0x03 = BBBB   write on S: CPU1 takes ownership
//   6  CPU0 read  0x03          miss: CPU1 flushes, CPU0 reads BBBB
//   7  CPU0 read  0x02          hit, AAAA
//   8  both at once: CPU0 writes 0x10 = 1111, CPU1 writes 0x11 = 2222 (same line): the bus serves one, then the other, and no write may get lost
//   9  CPU0 reads 0x10 and 0x11, CPU1 reads 0x10
//
// A checker looks at both caches on every clock: a line that is in M in one cache can never be valid in the other one
//=============================================================

module coh_TB;

	parameter WAYS = 2;

	localparam SETS = 8;

	logic clk, rst;

	// CPU side of each cache, [cpu]
	logic [1:0]        req_valid, req_we, resp_ready;
	logic [1:0][24:0]  req_addr;
	logic [1:0][15:0]  req_wdata, resp_rdata;

	// between the caches and the bus
	logic [1:0]                  bus_req, bus_done;
	logic [1:0][1:0]             bus_cmd;
	logic [1:0][22:0]            bus_addr;
	logic [1:0][3:0][15:0]       bus_wdata;
	logic [3:0][15:0]            bus_rdata;
	logic [1:0]                  snoop_valid, snoop_done, snoop_flush;
	logic [1:0]                  snoop_cmd;
	logic [22:0]                 snoop_addr;
	logic [1:0][3:0][15:0]       snoop_line;

	// between the bus and the memory
	logic              mem_valid, mem_we, mem_ready;
	logic [22:0]       mem_addr;
	logic [3:0][15:0]  mem_wdata, mem_rdata;

	// events of each cache
	logic [1:0] ev_hit, ev_miss, ev_upgrade, ev_evict, ev_inval, ev_flush;
	int hits[2], misses[2], upgrades[2], evictions[2], invals[2], flushes[2];
	int wrong = 0, swmr_errors = 0, step = 0;

	// the two caches
	for (genvar c = 0; c < 2; c++) begin : cpu
		coh_cache #(.WAYS(WAYS)) cache (
			.clk(clk), .rst(rst),
			.req_valid(req_valid[c]), 
			.req_we(req_we[c]),
			.req_addr(req_addr[c]), 
			.req_wdata(req_wdata[c]),
			.resp_ready(resp_ready[c]), 
			.resp_rdata(resp_rdata[c]),
			.bus_req(bus_req[c]), 
			.bus_cmd(bus_cmd[c]), 
			.bus_addr(bus_addr[c]),
			.bus_wdata(bus_wdata[c]), 
			.bus_done(bus_done[c]), 
			.bus_rdata(bus_rdata),
			.snoop_valid(snoop_valid[c]), 
			.snoop_cmd(snoop_cmd), 
			.snoop_addr(snoop_addr),
			.snoop_done(snoop_done[c]), 
			.snoop_flush(snoop_flush[c]), 
			.snoop_line(snoop_line[c]),
			.ev_hit(ev_hit[c]), 
			.ev_miss(ev_miss[c]), 
			.ev_upgrade(ev_upgrade[c]),
			.ev_evict(ev_evict[c]), 
			.ev_inval(ev_inval[c]), 
			.ev_flush(ev_flush[c])
		);
	end

	coh_bus bus (
		.clk(clk), 
		.rst(rst),
		.bus_req(bus_req), 
		.bus_cmd(bus_cmd), 
		.bus_addr(bus_addr), 
		.bus_wdata(bus_wdata),
		.bus_done(bus_done), 
		.bus_rdata(bus_rdata),
		.snoop_valid(snoop_valid), 
		.snoop_cmd(snoop_cmd), 
		.snoop_addr(snoop_addr),
		.snoop_done(snoop_done), 
		.snoop_flush(snoop_flush), 
		.snoop_line(snoop_line),
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

	always #10 clk = ~clk; // 50 MHz

	// count the events of both caches
	always @(posedge clk) begin
		for (int c = 0; c < 2; c++) begin
			if (ev_hit[c])     hits[c]++;
			if (ev_miss[c])    misses[c]++;
			if (ev_upgrade[c]) upgrades[c]++;
			if (ev_evict[c])   evictions[c]++;
			if (ev_inval[c])   invals[c]++;
			if (ev_flush[c])   flushes[c]++;
		end
	end

	// the rule of coherence: a line in M in one cache can never be valid in the other one (single writer, or many readers)
	always @(posedge clk) begin
		if (!rst) begin
			for (int s = 0; s < SETS; s++)
				for (int w0 = 0; w0 < WAYS; w0++)
					for (int w1 = 0; w1 < WAYS; w1++)
						if (cpu[0].cache.tag_store.valid[s][w0] && cpu[1].cache.tag_store.valid[s][w1] &&
						    cpu[0].cache.tag_store.tags[s][w0] == cpu[1].cache.tag_store.tags[s][w1] &&
						    (cpu[0].cache.tag_store.dirty[s][w0] || cpu[1].cache.tag_store.dirty[s][w1])) begin
							$error("SWMR: set %0d is in M in one cache and valid in the other", s);
							swmr_errors++;
						end
		end
	end

	// one access from one CPU, holding the request until resp_ready
	task automatic access(input int c, input logic we, input logic [24:0] addr,
	                      input logic [15:0] wdata, input logic [15:0] expected);
		logic [15:0] rdata;
		int          cycles = 0;
		@(negedge clk);
		req_valid[c] = 1; req_we[c] = we; req_addr[c] = addr; req_wdata[c] = wdata;
		do begin
			@(negedge clk);
			cycles++;
		end while (!resp_ready[c]);
		rdata = resp_rdata[c];
		@(negedge clk);
		req_valid[c] = 0; req_we[c] = 0;
		step++;
		if (we)
			$display("%2d  CPU%0d write %h = %h   %0d cycles", step, c, addr, wdata, cycles + 1);
		else begin
			$display("%2d  CPU%0d read  %h -> %h   %0d cycles%s", step, c, addr, rdata, cycles + 1,
			         (rdata == expected) ? "" : "   <-- WRONG");
			if (rdata != expected) wrong++;
		end
	endtask

	initial begin
		clk = 0; rst = 1;
		req_valid = '0; req_we = '0; req_addr = '0; req_wdata = '0;
		repeat (2) @(negedge clk);
		rst = 0;

		//     cpu we address data      expected
		access(0,  0, 25'h00, 16'h0000, 16'h0000);
		access(1,  0, 25'h01, 16'h0000, 16'h0001);
		access(0,  1, 25'h02, 16'hAAAA, 16'h0000);
		access(1,  0, 25'h02, 16'h0000, 16'hAAAA);
		access(1,  1, 25'h03, 16'hBBBB, 16'h0000);
		access(0,  0, 25'h03, 16'h0000, 16'hBBBB);
		access(0,  0, 25'h02, 16'h0000, 16'hAAAA);
		fork // both at the same time
			access(0, 1, 25'h10, 16'h1111, 16'h0000);
			access(1, 1, 25'h11, 16'h2222, 16'h0000);
		join
		access(0,  0, 25'h10, 16'h0000, 16'h1111);
		access(0,  0, 25'h11, 16'h0000, 16'h2222);
		access(1,  0, 25'h10, 16'h0000, 16'h1111);

		repeat (2) @(negedge clk);
		$display("--------------------------------------------------------------");
		for (int c = 0; c < 2; c++)
			$display("CPU%0d: hits %0d, misses %0d, upgrades %0d, evictions %0d, invalidated %0d, flushes %0d",
			         c, hits[c], misses[c], upgrades[c], evictions[c], invals[c], flushes[c]);
		$display("memory: %0d lines read, %0d written", memory.line_reads, memory.line_writes);
		$display("wrong reads = %0d, coherence errors = %0d", wrong, swmr_errors);
		$stop;
	end

endmodule
