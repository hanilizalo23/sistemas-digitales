`timescale 1ns/1ps

//=============================================================
// mem_model
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
// Fake main memory for simulation (not synthesizable), works with whole lines and takes LATENCY clocks per request
//
// Takes a request when mem_valid is high and it is free, when done, pulses mem_ready for one clock
// A new request never starts in that same clock
//
// Every word starts holding its own address, so a read shows where it came from
//=============================================================

module mem_model #(
	parameter WORD_W      = 16, // bits of a word
	parameter WORDS       = 4,  // words per line
	parameter LINE_ADDR_W = 23, // bits of a line address
	parameter DEPTH_W     = 12, // only 4096 lines, enough for the tests
	parameter LATENCY     = 4   // clocks per request
) (
	input  logic                          clk,
	input  logic                          rst,
	input  logic                          mem_valid, // request from the cache
	input  logic                          mem_we,    // 1: write the line, 0: read it
	input  logic [LINE_ADDR_W-1:0]        mem_addr,  // line address
	input  logic [WORDS-1:0][WORD_W-1:0]  mem_wdata, // line to write
	output logic                          mem_ready, // one-clock pulse: done
	output logic [WORDS-1:0][WORD_W-1:0]  mem_rdata  // line read
);

	logic [WORDS-1:0][WORD_W-1:0] mem [1<<DEPTH_W]; // the memory itself

	// copy of the request being served
	logic                         busy, we_q;
	logic [DEPTH_W-1:0]           addr_q;
	logic [WORDS-1:0][WORD_W-1:0] wdata_q;
	int                           count; // clocks left

	int line_reads  = 0; // to print at the end of the test
	int line_writes = 0;

	// every word starts with its own word address
	initial begin
		for (int i = 0; i < (1<<DEPTH_W); i++)
			for (int k = 0; k < WORDS; k++)
				mem[i][k] = WORD_W'(i*WORDS + k);
	end

	always @(posedge clk) begin // plain always: mem is also filled by the initial block
		if (rst) begin
			busy      <= 1'b0;
			mem_ready <= 1'b0;
		end
		else begin
			mem_ready <= 1'b0; // ready only lasts one clock
			if (!busy && !mem_ready && mem_valid) begin
				busy    <= 1'b1; // take the request
				we_q    <= mem_we;
				addr_q  <= mem_addr[DEPTH_W-1:0];
				wdata_q <= mem_wdata;
				count   <= LATENCY;
			end
			else if (busy) begin
				count <= count - 1; // wait
				if (count == 1) begin // last clock: do it
					busy      <= 1'b0;
					mem_ready <= 1'b1;
					if (we_q) begin
						mem[addr_q] <= wdata_q; // write-back
						line_writes <= line_writes + 1;
					end
					else begin
						mem_rdata  <= mem[addr_q]; // line read
						line_reads <= line_reads + 1;
					end
				end
			end
		end
	end

endmodule
