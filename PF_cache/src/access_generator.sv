`timescale 1ns/1ps

//=============================================================
// access_generator
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/21/2026
//-------------------------------------------------------------
// Plays the CPU: sends the accesses of one pattern to the cache, one at a time, and waits for resp_ready before each next one
//
//   pattern 0, LOOP     reads LOOP_WORDS words in a row, LOOP_PASSES times
//   pattern 1, STREAM   reads STREAM_WORDS words in a row, once
//   pattern 2, CONFLICT writes word 0 of CONFLICT_LINES lines that all fall in set 0, CONFLICT_PASSES times
//
// start picks the pattern and begins, done stays high when it finishes, until the next start
//=============================================================

module access_generator #(
	parameter ADDR_W          = 25,  // bits of a word address
	parameter WORD_W          = 16,  // bits of a word
	parameter SETS            = 8,   // sets of the cache
	parameter WORDS           = 4,   // words per line
	parameter LOOP_WORDS      = 96,  // size of the loop array
	parameter LOOP_PASSES     = 4,   // times the loop runs
	parameter STREAM_WORDS    = 256, // size of the stream
	parameter CONFLICT_LINES  = 3,   // lines fighting for set 0
	parameter CONFLICT_PASSES = 16   // times they are visited
) (
	input  logic              clk,
	input  logic              rst,
	input  logic              start,       // begin a pattern
	input  logic [1:0]        pattern_sel, // which one
	output logic              req_valid,   // request to the cache
	output logic              req_we,
	output logic [ADDR_W-1:0] req_addr,
	output logic [WORD_W-1:0] req_wdata,
	input  logic              resp_ready,  // the cache finished the access
	output logic              done         // pattern finished
);

	localparam [1:0] LOOP = 2'd0, STREAM = 2'd1, CONFLICT = 2'd2;

	// words between two lines that land in the same set (8 sets x 4 words = 32)
	localparam STRIDE = SETS * WORDS;

	typedef enum logic [1:0] {IDLE, RUN, FINISHED} state_t;

	state_t      state;
	logic [1:0]  pattern;       // pattern being run (kept from start)
	logic [15:0] item;          // position inside one pass
	logic [15:0] pass;          // which pass
	logic [15:0] items, passes; // size of the pattern being run

	// size of each pattern
	always_comb begin
		case (pattern)
			LOOP:     begin items = LOOP_WORDS;     passes = LOOP_PASSES;     end
			STREAM:   begin items = STREAM_WORDS;   passes = 1;               end
			default:  begin items = CONFLICT_LINES; passes = CONFLICT_PASSES; end
		endcase
	end

	always_ff @(posedge clk) begin
		if (rst) begin
			state   <= IDLE;
			pattern <= LOOP;
			item    <= '0;
			pass    <= '0;
		end
		else begin
			case (state)
				IDLE, FINISHED:
					if (start) begin
						pattern <= pattern_sel; // keep the pattern for the whole run
						item    <= '0;
						pass    <= '0;
						state   <= RUN;
					end
				RUN:
					if (resp_ready) begin               // this access is done
						if (item == items - 1'b1) begin // last one of the pass
							item <= '0;
							if (pass == passes - 1'b1)
								state <= FINISHED;      // last pass too
							else
								pass <= pass + 1'b1;    // next pass
						end
						else
							item <= item + 1'b1;        // next access
					end
				default:
					state <= IDLE;
			endcase
		end
	end

	// one request after the other while running
	assign req_valid = (state == RUN);
	assign done      = (state == FINISHED);

	// address of the current access
	always_comb begin
		case (pattern)
			LOOP:     req_addr = ADDR_W'(item);          // words 0, 1, 2...
			STREAM:   req_addr = ADDR_W'(item);          // same, but only once
			default:  req_addr = ADDR_W'(item * STRIDE); // 0, 32, 64: all in set 0
		endcase
	end

	assign req_we    = (pattern == CONFLICT); // only the conflict pattern writes
	assign req_wdata = WORD_W'(req_addr);     // write the address as data

endmodule
