//=============================================================
// add_sub
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Adder/subtractor from full adders
// When sub = 0 --> a + b
// When sub = 1 --> a - b, by feeding the adder with the inverted b and a carry in of 1 (two's complement)
//
// Ports:
//   a, b: operands, WIDTH-bits, two's complement
//   sub: 0 for addition, 1 for subtraction
//   result: WIDTH-bit result
//   carry: carry out, for unsigned numbers
//   overflow: set when the signed result doesn't fit
//=============================================================

module add_sub #(
	parameter WIDTH = 8
) (
	input  wire [WIDTH-1:0] a,
	input  wire [WIDTH-1:0] b,
	input  wire             sub,
	output wire [WIDTH-1:0] result,
	output wire             carry, // carry out of the last stage, on subtraction it means "no borrow" (a >= b) --> borrow = ~carry
	output wire             overflow
);

	// invert b when subtracting
	wire [WIDTH-1:0] b_operand;

	genvar i;
	generate
		for (i = 0; i < WIDTH; i = i + 1) begin : invert_b
			assign b_operand[i] = b[i] ^ sub; // sub = 0 --> b passes through, sub = 1 --> ~b
		end
	endgenerate

	// carry chain, one more wire so every stage has its own
	wire [WIDTH:0] chain;

	// the same sub signal supplies the +1 of two's complement
	assign chain[0] = sub;
	assign carry    = chain[WIDTH];

	generate
		for (i = 0; i < WIDTH; i = i + 1) begin : adder_chain
			full_adder bit_adder (
				.a    (a[i]),
				.b    (b_operand[i]),
				.cin  (chain[i]),
				.sum  (result[i]),
				.cout (chain[i+1])
			);
		end
	endgenerate

	// overflow --> both operands have the same sign and the result has the other one
	assign overflow = (a[WIDTH-1] == b_operand[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);

endmodule
