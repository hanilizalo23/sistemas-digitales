//=============================================================
// alu
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Arithmetic logic unit, parameterized on LENGTH
// Add and subtract are built from an instantiated add_sub (full adders), multiplication from an instantiated array_multiplier
// The rest of the operations use Verilog operators
//
// Result is wider than the operands so that sums and products fit without losing information
//
// Ports:
//   a, b: operands, LENGTH bits, two's complement
//   control: selects the operation, see table below
//   result: 2*LENGTH-2 bits, two's complement
//   zero: result is zero
//   negative: result is negative (arithmetic operations only)
//   carry: carry out of add/subtract
//   overflow: signed overflow of add/subtract
//
// control  operation
//   0      a + b
//   1      a - b
//   2      -b
//   3      a * b
//   4      a AND b
//   5      a OR b
//   6      NOT a
//   7      a XOR b
//   8      a << b[3:0]
//   9      a >> b[3:0]
//=============================================================

module alu #(
	parameter LENGTH = 5
) (
	input  wire signed [LENGTH-1:0]   a,
	input  wire signed [LENGTH-1:0]   b,
	input  wire        [3:0]          control,
	output reg  signed [2*LENGTH-3:0] result, // 8 bits when LENGTH = 5
	output reg                        zero,
	output reg                        negative,
	output reg                        carry,
	output reg                        overflow
);

	localparam RWIDTH = 2*LENGTH - 2; // result width, 8 bits when LENGTH = 5
	localparam DROPPED = 2*LENGTH - RWIDTH + 1; // 3 when LENGTH = 5, for multiplication overflow

	// operands sign extended to the result width
	wire signed [RWIDTH-1:0] a_ext = {{(RWIDTH-LENGTH){a[LENGTH-1]}}, a};
	wire signed [RWIDTH-1:0] b_ext = {{(RWIDTH-LENGTH){b[LENGTH-1]}}, b};

	// zero, used when the operation needs -b instead of a - b
	wire signed [RWIDTH-1:0] const_zero = {RWIDTH{1'b0}};

	// adder/subtractor ------------------
	wire [RWIDTH-1:0] sum_a;        // first operand feeding the adder
	wire              do_sub;       // 0 adds, 1 subtracts
	wire [RWIDTH-1:0] sum_result;
	wire              sum_carry;
	wire              sum_overflow;

	// control 2 --> 0 - b, everything else uses a
	assign sum_a  = (control == 4'd2) ? const_zero : a_ext;
	assign do_sub = (control == 4'd1) || (control == 4'd2); // control 0 --> do_sub = 0 (just adder)

	add_sub #(.WIDTH(RWIDTH)) adder_unit (
		.a        (sum_a),
		.b        (b_ext),
		.sub      (do_sub),
		.result   (sum_result),
		.carry    (sum_carry),
		.overflow (sum_overflow)
	);

	// multiplier ------------------
	wire [2*LENGTH-1:0] mult_full;   // full product, truncated
	
	// bits that will be "dropped" [9:8], plus the bit that becomes the new sign [7]
	wire [DROPPED-1:0] top_bits = mult_full[2*LENGTH-1:RWIDTH-1];

	// the truncated product is valid only when those bits are all equal
	wire mult_overflow = (top_bits != {DROPPED{1'b0}}) && (top_bits != {DROPPED{1'b1}});

	signed_multiplier #(.WIDTH(LENGTH)) mult_unit (
		.a (a),
		.b (b),
		.y (mult_full)
	);

	// operation select ------------------
	always @(*) begin
		// defaults, so every path assigns every output and no latch is inferred
		result   = {RWIDTH{1'b0}};
		zero     = 1'b0;
		negative = 1'b0;
		carry    = 1'b0;
		overflow = 1'b0;

		case (control)
			4'd0: begin // --------------------> add
				result   = sum_result;
				carry    = sum_carry;
				overflow = sum_overflow;
				negative = sum_result[RWIDTH-1];
			end
			4'd1: begin // --------------------> subtract
				result   = sum_result;
				carry    = sum_carry;
				overflow = sum_overflow;
				negative = sum_result[RWIDTH-1];
			end
			4'd2: begin // --------------------> negate b
				result   = sum_result;
				overflow = sum_overflow;
				negative = sum_result[RWIDTH-1];
			end
			4'd3: begin // --------------------> multiply
				result   = mult_full[RWIDTH-1:0];
				negative = mult_full[RWIDTH-1];
				overflow = mult_overflow; // product doesn't fit in RWIDTH
			end
			4'd4:  result = a_ext & b_ext;    // and
			4'd5:  result = a_ext | b_ext;    // or
			4'd6:  result = ~a_ext;           // not a
			4'd7:  result = a_ext ^ b_ext;    // xor
			4'd8:  result = a_ext << b[3:0];  // shift left
			4'd9:  result = a_ext >> b[3:0];  // shift right
			default: ;                        // unused control codes --> outputs stay at their default value
		endcase
		
		// applies to every operation, after the case
		zero = (result == const_zero);
	end

endmodule
