`timescale 1ns/1ps

//=============================================================
// coh_cache
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/22/2026
//-------------------------------------------------------------
// N-way set associative cache that stays coherent with other caches on a shared bus, with the MSI protocol
// The states live in the bits it already had:
//
//   I  invalid   valid = 0
//   S  shared    valid = 1, dirty = 0  (clean, others may have it)
//   M  modified  valid = 1, dirty = 1  (only copy, written)
//
// CPU side: the same as cache
// Bus side: requests (BUS_RD, BUS_RDX, BUS_WB) held until bus_done
// Snoop side: the bus tells this cache what another cache is asking for:
//
//   another asks BUS_RD  -> if we have it in M: hand it to memory, go to S
//   another asks BUS_RDX -> if we have it: hand it over if M, then go to I
//
// A snoop waits while the FSM is in COMPARE, so it never meets a CPU write in the same clock
//=============================================================

module coh_cache #(
	parameter WAYS   = 4,  // ways per set (2, 4 or 8)
	parameter SETS   = 8,  // number of sets
	parameter WORD_W = 16, // bits of a word
	parameter WORDS  = 4,  // words per line
	parameter ADDR_W = 25  // bits of a word address
) (
	input  logic                            clk,
	input  logic                            rst,
	// CPU side
	input  logic                            req_valid,   // there is a request, held until resp_ready
	input  logic                            req_we,      // 1: write, 0: read
	input  logic [ADDR_W-1:0]               req_addr,    // word address
	input  logic [WORD_W-1:0]               req_wdata,   // word to write
	output logic                            resp_ready,  // one-clock pulse: access done
	output logic [WORD_W-1:0]               resp_rdata,  // word read (valid with resp_ready)
	// bus side: our requests
	output logic                            bus_req,     // held until bus_done
	output logic [1:0]                      bus_cmd,     // BUS_RD, BUS_RDX or BUS_WB
	output logic [ADDR_W-$clog2(WORDS)-1:0] bus_addr,    // line address
	output logic [WORDS-1:0][WORD_W-1:0]    bus_wdata,   // line to write back
	input  logic                            bus_done,    // the bus finished our request
	input  logic [WORDS-1:0][WORD_W-1:0]    bus_rdata,   // line read
	// snoop side: what another cache is asking for
	input  logic                            snoop_valid, // held until snoop_done
	input  logic [1:0]                      snoop_cmd,   // BUS_RD or BUS_RDX
	input  logic [ADDR_W-$clog2(WORDS)-1:0] snoop_addr,  // line address
	output logic                            snoop_done,  // we handled it
	output logic                            snoop_flush, // we had it in M: here is the line
	output logic [WORDS-1:0][WORD_W-1:0]    snoop_line,  // the line to hand to memory
	// events for the counters (one-clock pulses)
	output logic                            ev_hit,
	output logic                            ev_miss,
	output logic                            ev_upgrade,  // write on a shared line
	output logic                            ev_evict,
	output logic                            ev_inval,    // another cache took our line
	output logic                            ev_flush     // we handed a modified line to memory
);

	// bus commands, the same values as in coh_bus
	localparam [1:0] BUS_RD = 2'd0, BUS_RDX = 2'd1, BUS_WB = 2'd2;

	// sizes that come from the parameters
	localparam OFFSET_W    = $clog2(WORDS);               // 2: word inside the line
	localparam INDEX_W     = $clog2(SETS);                // 3: set
	localparam TAG_W       = ADDR_W - INDEX_W - OFFSET_W; // 20: what is left
	localparam WAY_W       = $clog2(WAYS);                // bits to number a way
	localparam LINE_ADDR_W = ADDR_W - OFFSET_W;           // 23: line address

	// pieces of the CPU address
	logic [OFFSET_W-1:0] req_offset;
	logic [INDEX_W-1:0]  req_index;
	logic [TAG_W-1:0]    req_tag;

	assign req_offset = req_addr[OFFSET_W-1:0];
	assign req_index  = req_addr[OFFSET_W +: INDEX_W];
	assign req_tag    = req_addr[ADDR_W-1 -: TAG_W];

	// pieces of the snooped line address (it has no offset)
	logic [INDEX_W-1:0] snoop_index;
	logic [TAG_W-1:0]   snoop_tag;

	assign snoop_index = snoop_addr[INDEX_W-1:0];
	assign snoop_tag   = snoop_addr[LINE_ADDR_W-1 -: TAG_W];

	// everything about the set of the request, one entry per way
	logic [WAYS-1:0]                        valid_set, dirty_set;
	logic [WAYS-1:0][TAG_W-1:0]             tag_set;
	logic [WAYS-1:0][WORDS-1:0][WORD_W-1:0] line_set;

	// everything about the snooped set
	logic [WAYS-1:0]                        snoop_valid_set, snoop_dirty_set;
	logic [WAYS-1:0][TAG_W-1:0]             snoop_tag_set;
	logic [WAYS-1:0][WORDS-1:0][WORD_W-1:0] snoop_line_set;

	logic             hit;        // CPU lookup
	logic [WAY_W-1:0] hit_way;
	logic             snoop_hit;  // snoop lookup
	logic [WAY_W-1:0] snoop_way;
	logic [WAY_W-1:0] victim_way; // way to replace on a miss
	logic [WAY_W-1:0] fill_way;   // way where the line from the bus goes
	logic             word_we, fill, upgrade, need_upgrade, in_compare;

	// state of the victim, for the FSM
	logic victim_valid, victim_dirty;
	assign victim_valid = valid_set[victim_way];
	assign victim_dirty = dirty_set[victim_way];

	// the FSM
	coh_cache_ctrl ctrl (
		.clk(clk), 
		.rst(rst),
		.req_valid(req_valid), 
		.req_we(req_we),
		.hit(hit), 
		.hit_dirty(dirty_set[hit_way]),
		.victim_valid(victim_valid), 
		.victim_dirty(victim_dirty),
		.bus_done(bus_done), 
		.bus_req(bus_req), 
		.bus_cmd(bus_cmd),
		.resp_ready(resp_ready), 
		.word_we(word_we), 
		.fill(fill),
		.upgrade(upgrade), 
		.need_upgrade(need_upgrade), 
		.in_compare(in_compare),
		.ev_hit(ev_hit), 
		.ev_miss(ev_miss), 
		.ev_upgrade(ev_upgrade), 
		.ev_evict(ev_evict)
	);

	// where the line from the bus goes: the victim on a miss, or the same way on an upgrade, decided in COMPARE and kept
	always_ff @(posedge clk) begin
		if (in_compare)
			fill_way <= need_upgrade ? hit_way : victim_way;
	end

	// snooping
	logic snoop_accept; // handle the snoop this clock
	logic snoop_we;     // and it changes one of our lines

	assign snoop_accept = snoop_valid && !in_compare; // wait while COMPARE works
	assign snoop_we     = snoop_accept && snoop_hit;  // only if we have the line

	assign snoop_done   = snoop_accept;
	assign snoop_flush  = snoop_we && snoop_dirty_set[snoop_way]; // we have it in M
	assign snoop_line   = snoop_line_set[snoop_way];

	assign ev_inval     = snoop_we && (snoop_cmd == BUS_RDX);
	assign ev_flush     = snoop_flush;

	// arrays
	// tags: written by the CPU side (write hit, fill) or by a snoop
	// they never happen in the same clock: snoops wait in COMPARE, and while our own bus request runs nobody else uses the bus
	tag_array #(.WAYS(WAYS), .SETS(SETS), .TAG_W(TAG_W)) tag_store (
		.clk(clk), 
		.rst(rst),
		.index(req_index),
		.valid_set(valid_set), 
		.dirty_set(dirty_set), 
		.tag_set(tag_set),
		.snoop_index(snoop_index),
		.snoop_valid_set(snoop_valid_set), 
		.snoop_dirty_set(snoop_dirty_set),
		.snoop_tag_set(snoop_tag_set),
		.we(word_we || fill || snoop_we),
		.w_index(snoop_we ? snoop_index : req_index),
		.w_way(snoop_we ? snoop_way : (fill ? fill_way : hit_way)),
		.w_valid(snoop_we ? (snoop_cmd == BUS_RD) : 1'b1), // BUS_RDX invalidates
		.w_dirty(!snoop_we && !fill),                      // only a write hit leaves it dirty
		.w_tag(snoop_we ? snoop_tag : req_tag)
	);

	// data: only the CPU side writes; the snoop side only reads
	data_array #(.WAYS(WAYS), .SETS(SETS), .WORD_W(WORD_W), .WORDS(WORDS)) data_store (
		.clk(clk),
		.index(req_index), 
		.line_set(line_set),
		.snoop_index(snoop_index), 
		.snoop_line_set(snoop_line_set),
		.line_we(fill), 
		.word_we(word_we),
		.w_way(fill ? fill_way : hit_way),
		.w_line(bus_rdata),
		.w_offset(req_offset), 
		.w_word(req_wdata)
	);

	// two lookups: one for the CPU, one for snooping
	hit_detect #(.WAYS(WAYS), .TAG_W(TAG_W)) hit_check (
		.valid_set(valid_set), 
		.tag_set(tag_set), 
		.tag(req_tag),
		.hit(hit), 
		.hit_way(hit_way)
	);

	hit_detect #(.WAYS(WAYS), .TAG_W(TAG_W)) snoop_check (
		.valid_set(snoop_valid_set), 
		.tag_set(snoop_tag_set), 
		.tag(snoop_tag),
		.hit(snoop_hit), 
		.hit_way(snoop_way)
	);

	// RR: moves only when a new line comes in on a miss
	replacement_rr #(.WAYS(WAYS), .SETS(SETS)) replacement (
		.clk(clk), 
		.rst(rst), 
		.index(req_index),
		.advance(fill && !upgrade), 
		.victim_way(victim_way)
	);

	// word read on a hit
	assign resp_rdata = line_set[hit_way][req_offset];

	// write-back goes where the victim lived, reads ask for the requested line
	assign bus_addr  = (bus_cmd == BUS_WB) ? {tag_set[victim_way], req_index} : {req_tag, req_index};
	assign bus_wdata = line_set[victim_way];

endmodule
