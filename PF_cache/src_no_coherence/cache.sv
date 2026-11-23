`timescale 1ns/1ps

//=============================================================
// cache
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/16/2026
//-------------------------------------------------------------
//
// Write-back: a write stays in the cache and its line gets dirty, memory only gets it when the line is replaced
// Write-through would send every write to memory as well, so no dirty bit and no write-back would be needed, it's an option for later
//
// Request side: one word,  the requester holds the request until resp_ready
// Memory side: one whole line, so it doesn't care what is behind (a model, the Avalon adapter or a bus)
//
// Word address (25 bits): [24:5] tag | [4:2] set | [1:0] offset
//=============================================================


module cache #(
	parameter WAYS   = 4,  // ways per set (2, 4 or 8)
	parameter SETS   = 8,  // number of sets
	parameter WORD_W = 16, // bits of a word (SDRAM width)
	parameter WORDS  = 4,  // words per line
	parameter ADDR_W = 25  // bits of a word address (32M words)
) (
	input  logic                          clk,
	input  logic                          rst,
	// request side (from whoever plays the CPU)
	input  logic                          req_valid,  // there is a request, held until resp_ready
	input  logic                          req_we,     // 1: write, 0: read
	input  logic [ADDR_W-1:0]             req_addr,   // word address
	input  logic [WORD_W-1:0]             req_wdata,  // word to write
	output logic                          resp_ready, // one-clock pulse: access done
	output logic [WORD_W-1:0]             resp_rdata, // word read (valid with resp_ready)
	// memory side (whole lines)
	output logic                          mem_valid,  // request to memory, held until mem_ready
	output logic                          mem_we,     // 1: write-back, 0: read a line
	output logic [ADDR_W-$clog2(WORDS)-1:0] mem_addr, // line address (no offset bits)
	output logic [WORDS-1:0][WORD_W-1:0]  mem_wdata,  // line to write
	input  logic                          mem_ready,  // memory finished
	input  logic [WORDS-1:0][WORD_W-1:0]  mem_rdata,  // line read
	// events for the counters (one-clock pulses)
	output logic                          ev_hit,
	output logic                          ev_miss,
	output logic                          ev_evict
);

	// sizes that come from the parameters
	localparam OFFSET_W = $clog2(WORDS);               // 2: word inside the line
	localparam INDEX_W  = $clog2(SETS);                // 3: set
	localparam TAG_W    = ADDR_W - INDEX_W - OFFSET_W; // 20: what is left
	localparam WAY_W    = $clog2(WAYS);                // bits to number a way

	// pieces of the address
	logic [OFFSET_W-1:0] req_offset;
	logic [INDEX_W-1:0]  req_index;
	logic [TAG_W-1:0]    req_tag;

	assign req_offset = req_addr[OFFSET_W-1:0];        // [1:0]
	assign req_index  = req_addr[OFFSET_W +: INDEX_W]; // [4:2]
	assign req_tag    = req_addr[ADDR_W-1 -: TAG_W];   // [24:5]

	// everything about the current set, one entry per way
	logic [WAYS-1:0]                        valid_set, dirty_set;
	logic [WAYS-1:0][TAG_W-1:0]             tag_set;
	logic [WAYS-1:0][WORDS-1:0][WORD_W-1:0] line_set; // line_set[way][word]

	logic             hit;        // lookup result
	logic [WAY_W-1:0] hit_way;    // way that matched
	logic [WAY_W-1:0] victim_way; // way to replace on a miss
	logic             word_we;    // FSM: write the word (write hit)
	logic             fill;       // FSM: store the line from memory

	// state of the victim, the FSM needs it to choose between WRITE_BACK (dirty) and ALLOCATE (empty or clean)
	logic victim_valid, victim_dirty;
	assign victim_valid = valid_set[victim_way];
	assign victim_dirty = dirty_set[victim_way];

	// the FSM
	cache_ctrl ctrl (
		.clk(clk), 
		.rst(rst),
		.req_valid(req_valid), 
		.req_we(req_we),
		.hit(hit), 
		.victim_valid(victim_valid), 
		.victim_dirty(victim_dirty),
		.mem_ready(mem_ready), 
		.mem_valid(mem_valid), 
		.mem_we(mem_we),
		.resp_ready(resp_ready), 
		.word_we(word_we), 
		.fill(fill),
		.ev_hit(ev_hit), 
		.ev_miss(ev_miss), 
		.ev_evict(ev_evict)
	);

	// valid, dirty and tag. Written in two cases:
	// write hit --> the hit way becomes dirty
	// fill      --> the victim way gets the new tag, clean
	tag_array #(.WAYS(WAYS), .SETS(SETS), .TAG_W(TAG_W)) tag_store (
		.clk(clk), 
		.rst(rst), 
		.index(req_index),
		.valid_set(valid_set), 
		.dirty_set(dirty_set), 
		.tag_set(tag_set),
		.we(word_we || fill),                // either case
		.w_way(fill ? victim_way : hit_way), // victim on a fill, hit way on a write
		.w_dirty(!fill),                     // fill: 0, write hit: 1
		.w_tag(req_tag)                      // fill: new tag, write hit: same tag
	);

	// data lines: a whole line on a fill, one word on a write hit (the same w_way works because they never happen together)
	data_array #(.WAYS(WAYS), .SETS(SETS), .WORD_W(WORD_W), .WORDS(WORDS)) data_store (
		.clk(clk), 
		.index(req_index), 
		.line_set(line_set),
		.line_we(fill), 
		.word_we(word_we),
		.w_way(fill ? victim_way : hit_way),
		.w_line(mem_rdata), // line from memory
		.w_offset(req_offset), 
		.w_word(req_wdata)
	);

	// lookup: compares the request tag against every way
	hit_detect #(.WAYS(WAYS), .TAG_W(TAG_W)) hit_check (
		.valid_set(valid_set), 
		.tag_set(tag_set), 
		.tag(req_tag),
		.hit(hit), 
		.hit_way(hit_way)
	);

	// round robin, moves only when a new line comes in
	replacement_rr #(.WAYS(WAYS), .SETS(SETS)) replacement (
		.clk(clk), 
		.rst(rst), 
		.index(req_index),
		.advance(fill), 
		.victim_way(victim_way)
	);

	// word read on a hit: first the way, then the word in the line
	assign resp_rdata = line_set[hit_way][req_offset];

	// write-back goes where the victim lived (its tag)
	// allocate asks for the requested line (its tag)
	// same set in both
	assign mem_addr  = mem_we ? {tag_set[victim_way], req_index} : {req_tag, req_index};
	assign mem_wdata = line_set[victim_way]; // only used on a write-back

endmodule
