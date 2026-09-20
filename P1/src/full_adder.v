//=============================================================
// full_adder
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Single bit adder, adds three bits and reports the result split into a sum bit and a carry bit, so that carries can be chained across a multi bit adder
//
// sum is 1 when an odd number of inputs is 1
// cout is 1 when at least two of the inputs are 1
//
// Ports:
//   a, b: bits to add
//   cin : carry coming from the previous stage
//   sum : result bit
//   cout: carry going to the next stage
//=============================================================

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
