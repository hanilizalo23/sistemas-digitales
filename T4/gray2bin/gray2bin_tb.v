`timescale 1ns/1ps

module gray2bin_tb;

	parameter WIDTH = 4;

	reg  [WIDTH-1:0] g;
	wire [WIDTH-1:0] b;

	integer i;

	gray2bin #(.WIDTH(WIDTH)) dut (.g(g), .b(b));

	initial begin
		$display("value | gray | binary");

		for (i = 0; i < (1 << WIDTH); i = i + 1) begin
			g = i ^ (i >> 1); // gray that corresponds to the value i
			#10;
			$display("  %2d  | %b | %b", i, g, b);
		end
		
		$stop;
	end

endmodule
