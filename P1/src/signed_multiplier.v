//=============================================================
// signed_multiplier
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Two's complement multiplier for the array_multiplier, which only handles unsigned operands
//
// The magnitude of a product doesn't depend on the signs, both operands are converted to magnitude, multiplied, and the result is negated when the input signs differ
//
// Ports:
//   a, b: operands, WIDTH bits, two's complement
//   y: product, 2*WIDTH bits, two's complement
//=============================================================

module signed_multiplier #(
	parameter WIDTH = 5
) (
	input  wire signed [WIDTH-1:0]   a,
	input  wire signed [WIDTH-1:0]   b,
	output wire signed [2*WIDTH-1:0] y
);

	// magnitude of each operand
	wire [WIDTH-1:0] a_mag = a[WIDTH-1] ? (~a + 1'b1) : a;
	wire [WIDTH-1:0] b_mag = b[WIDTH-1] ? (~b + 1'b1) : b;

	// unsigned product of the magnitudes
	wire [2*WIDTH-1:0] product;

	array_multiplier #(.WIDTH(WIDTH)) mult_unit (
		.a (a_mag),
		.b (b_mag),
		.y (product)
	);

	// the product is negative when the operand signs differ
	wire result_is_neg = a[WIDTH-1] ^ b[WIDTH-1];

	// apply the sign back
	assign y = result_is_neg ? (~product + 1'b1) : product;

endmodule
