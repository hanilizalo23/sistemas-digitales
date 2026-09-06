`timescale 1ns/1ps

module mux2to1_tb;

	reg  [3:0] d0;
	reg  [3:0] d1;
	reg        s;
	wire [3:0] y;

	mux2to1 #(.WIDTH(4)) dut (
		.d0(d0), .d1(d1), .s(s), .y(y)
	);

	initial begin
		$display("time  s | d0   d1   | y");

		d0 = 4'b1010; d1 = 4'b0101;
		s = 0; #10; $display("%4t  %b | %b %b | %b", $time, s, d0, d1, y);
		s = 1; #10; $display("%4t  %b | %b %b | %b", $time, s, d0, d1, y);

		d0 = 4'b1111; d1 = 4'b0000;
		s = 0; #10; $display("%4t  %b | %b %b | %b", $time, s, d0, d1, y);
		s = 1; #10; $display("%4t  %b | %b %b | %b", $time, s, d0, d1, y);

		d0 = 4'b0011; d1 = 4'b1100;
		s = 0; #10; $display("%4t  %b | %b %b | %b", $time, s, d0, d1, y);
		s = 1; #10; $display("%4t  %b | %b %b | %b", $time, s, d0, d1, y);

		$stop;
	end

endmodule