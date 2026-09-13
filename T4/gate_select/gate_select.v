module gate_select #(
	parameter GATE = 0
) (
	input  wire a,
	input  wire b,
	output wire y
);

	generate
		case (GATE)
			0: assign y = ~(a & b); // NAND
			1: assign y = ~(a | b); // NOR
			2: assign y =   a ^ b;  // XOR
			3: assign y =   a & b;  // AND
			4: assign y =   a | b;  // OR
			default: assign y = 1'b0;
		endcase
	endgenerate

endmodule
