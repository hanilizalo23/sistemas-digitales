module adder_nbit #(
	parameter WIDTH = 4
) (
	input  wire [WIDTH-1:0] a,
	input  wire [WIDTH-1:0] b,
	output wire [WIDTH-1:0] sum, 
	output wire             cout // overflow bit
);

	// WIDTH+1 wires in total
	wire [WIDTH:0] carry;

	assign carry[0] = 1'b0; // nothing is carried in the first one
	assign cout     = carry[WIDTH]; // goes nowhere

	genvar i;
	generate
		for (i = 0; i < WIDTH; i = i + 1) begin : adder_chain
			full_adder bit_adder (
				.a    (a[i]),
				.b    (b[i]),
				.cin  (carry[i]), // carry from the element on the right
				.sum  (sum[i]),
				.cout (carry[i+1]) // carry from the element on the left
			);
		end
	endgenerate

endmodule
