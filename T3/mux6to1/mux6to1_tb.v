`timescale 1ns / 1ps

module mux6to1_tb;

	reg  [2:0] s;
	reg        d0, d1, d2, d3, d4, d5;
	wire       y;

	integer i;

	mux6to1 dut (
		.d0(d0), .d1(d1), .d2(d2),
		.d3(d3), .d4(d4), .d5(d5),
		.s(s), .y(y)
	);

	initial begin
		d0 = 1'b1;
		d1 = 1'b0;
		d2 = 1'b1;
		d3 = 1'b0;
		d4 = 1'b1;
		d5 = 1'b0;

		$display("s   | y");
		for (i = 0; i < 8; i = i + 1) begin
			s = i;
			#10;
			$display("%b | %b", s, y);
		end

		d0 = 1'b0;
		d1 = 1'b1;
		d2 = 1'b0;
		d3 = 1'b1;
		d4 = 1'b0;
		d5 = 1'b1;

		$display("--- inverted inputs ---");
		for (i = 0; i < 8; i = i + 1) begin
			s = i;
			#10;
			$display("%b | %b", s, y);
		end

		$stop;
	end

endmodule