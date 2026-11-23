`timescale 1ns/1ps

//=============================================================
// coh_bus
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/22/2026
//-------------------------------------------------------------
// Shared bus between two coherent caches and the memory
// One request at a time, from start to end (atomic bus)
// A round Robin Arbiter picks the next cache when both ask
//
// For each request:
//   BUS_WB          write the line to memory
//   BUS_RD, BUS_RDX first ask the other cache (snoop), if it had the line in M, it hands it over and the bus writes it to memory (FLUSH), then the line is read from memory
//
// Memory handshake as in mem_model: mem_valid stays high until mem_ready
//=============================================================

module coh_bus #(
	parameter WORD_W      = 16, // bits of a word
	parameter WORDS       = 4,  // words per line
	parameter LINE_ADDR_W = 23  // bits of a line address
) (
	input  logic                                clk,
	input  logic                                rst,
	// requests of the two caches
	input  logic [1:0]                          bus_req,     // one bit per cache
	input  logic [1:0][1:0]                     bus_cmd,
	input  logic [1:0][LINE_ADDR_W-1:0]         bus_addr,
	input  logic [1:0][WORDS-1:0][WORD_W-1:0]   bus_wdata,
	output logic [1:0]                          bus_done,    // pulse to the cache that asked
	output logic [WORDS-1:0][WORD_W-1:0]        bus_rdata,   // line read, for whoever asked
	// snoops to the two caches
	output logic [1:0]                          snoop_valid, // only to the other cache
	output logic [1:0]                          snoop_cmd,
	output logic [LINE_ADDR_W-1:0]              snoop_addr,
	input  logic [1:0]                          snoop_done,
	input  logic [1:0]                          snoop_flush,
	input  logic [1:0][WORDS-1:0][WORD_W-1:0]   snoop_line,
	// memory
	output logic                                mem_valid,
	output logic                                mem_we,
	output logic [LINE_ADDR_W-1:0]              mem_addr,
	output logic [WORDS-1:0][WORD_W-1:0]        mem_wdata,
	input  logic                                mem_ready,
	input  logic [WORDS-1:0][WORD_W-1:0]        mem_rdata
);

	// bus commands, the same values as in coh_cache
	localparam [1:0] BUS_RD = 2'd0, BUS_RDX = 2'd1, BUS_WB = 2'd2;

	typedef enum logic [1:0] {IDLE, SNOOP, FLUSH, MEM} state_t;

	state_t                       state;
	logic                         owner;   // cache being served
	logic                         last;    // cache served last time (for RR)
	logic                         pick;    // cache to serve next
	logic                         other;   // the cache that gets snooped
	logic [1:0]                   cmd_q;   // copy of the request
	logic [LINE_ADDR_W-1:0]       addr_q;
	logic [WORDS-1:0][WORD_W-1:0] wdata_q;
	logic [WORDS-1:0][WORD_W-1:0] flush_q; // line handed over by the other cache

	// RR: if both ask, the one that didn't go last
	assign pick  = (bus_req[0] && bus_req[1]) ? !last : bus_req[1];
	assign other = !owner;

	always_ff @(posedge clk) begin
		if (rst) begin
			state <= IDLE;
			owner <= 1'b0;
			last  <= 1'b1; // so cache 0 wins the first tie
		end
		else begin
			case (state)
				IDLE:
					if (|bus_req) begin           // somebody asks
						owner   <= pick;
						last    <= pick;
						cmd_q   <= bus_cmd[pick]; // keep the request
						addr_q  <= bus_addr[pick];
						wdata_q <= bus_wdata[pick];
						state   <= (bus_cmd[pick] == BUS_WB) ? MEM : SNOOP;
					end
				SNOOP:
					if (snoop_done[other]) begin          // the other cache answered
						if (snoop_flush[other]) begin
							flush_q <= snoop_line[other]; // it had the line in M
							state   <= FLUSH;
						end
						else
							state <= MEM;
					end
				FLUSH:
					if (mem_ready) state <= MEM;  // memory is up to date
				MEM:
					if (mem_ready) state <= IDLE; // request done
			endcase
		end
	end

	// snoop only the other cache
	always_comb begin
		snoop_valid        = 2'b00;
		snoop_valid[other] = (state == SNOOP);
	end
	assign snoop_cmd  = cmd_q;
	assign snoop_addr = addr_q;

	// memory: FLUSH writes the handed-over line, MEM does the request
	assign mem_valid = (state == FLUSH) || (state == MEM);
	assign mem_we    = (state == FLUSH) || (cmd_q == BUS_WB);
	assign mem_addr  = addr_q;                                  // same line in both
	assign mem_wdata = (state == FLUSH) ? flush_q : wdata_q;

	// answer the cache that asked
	always_comb begin
		bus_done        = 2'b00;
		bus_done[owner] = (state == MEM) && mem_ready;
	end
	assign bus_rdata = mem_rdata;

endmodule
