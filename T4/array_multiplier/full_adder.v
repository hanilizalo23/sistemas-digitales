module full_adder (
	input  wire a,
	input  wire b,
	input  wire cin, // carry coming from the previous stage
	output wire sum,
	output wire cout // carry going to the next stage
);

	assign sum  = a ^ b ^ cin; // sum is 1 when an odd number of inputs is 1
	assign cout = (a & b) | (a & cin) | (b & cin); // carry out is 1 when at least two inputs are 1

endmodule
