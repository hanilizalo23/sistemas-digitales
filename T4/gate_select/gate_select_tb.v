`timescale 1ns/1ps

module gate_select_tb;

	reg a, b;

	wire y_nand;
	wire y_nor;
	wire y_xor;
	wire y_and;
	wire y_or;

	integer i;

	gate_select #(.GATE(0)) dut_nand (.a(a), .b(b), .y(y_nand));
	gate_select #(.GATE(1)) dut_nor  (.a(a), .b(b), .y(y_nor));
	gate_select #(.GATE(2)) dut_xor  (.a(a), .b(b), .y(y_xor));
	gate_select #(.GATE(3)) dut_and  (.a(a), .b(b), .y(y_and));
	gate_select #(.GATE(4)) dut_or   (.a(a), .b(b), .y(y_or));

	initial begin
		$display("a b | nand nor xor and or");

		for (i = 0; i < 4; i = i + 1) begin
			{a, b} = i;
			#10;
			$display("%b %b |  %b    %b   %b   %b   %b",
			         a, b, y_nand, y_nor, y_xor, y_and, y_or);
		end

		$stop;
	end

endmodule
