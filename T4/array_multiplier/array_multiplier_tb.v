`timescale 1ns/1ps

module array_multiplier_tb;

	parameter W = 4;

	reg  [W-1:0] a;
	reg  [W-1:0] b;
	//wire [W-1:0] y;
    wire [2*W-1:0] y;

	reg [2*W-1:0] expected;

	integer i, j;
	integer errors;

	array_multiplier #(.WIDTH(W)) dut (.a(a), .b(b), .y(y));

	initial begin
		errors = 0;

		for (i = 0; i < (1 << W); i = i + 1) begin
			for (j = 0; j < (1 << W); j = j + 1) begin
				a = i;
				b = j;
				#10;

				expected = a * b;

				if (y != expected) begin
					errors = errors + 1;
					$display("FAIL:  a=%0d  b=%0d  expected=%0d  got=%0d",
					         a, b, expected, y);
				end
			end
		end

		$display("errors: %0d", errors);
		$stop;
	end

endmodule