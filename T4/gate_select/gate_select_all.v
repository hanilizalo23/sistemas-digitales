module gate_select_all (
	input  wire a,
	input  wire b,
	output wire y_nand,
	output wire y_nor,
	output wire y_xor,
	output wire y_and,
	output wire y_or
);

	gate_select #(.GATE(0)) gate_nand (.a(a), .b(b), .y(y_nand));
	gate_select #(.GATE(1)) gate_nor  (.a(a), .b(b), .y(y_nor));
	gate_select #(.GATE(2)) gate_xor  (.a(a), .b(b), .y(y_xor));
	gate_select #(.GATE(3)) gate_and  (.a(a), .b(b), .y(y_and));
	gate_select #(.GATE(4)) gate_or   (.a(a), .b(b), .y(y_or));

endmodule
