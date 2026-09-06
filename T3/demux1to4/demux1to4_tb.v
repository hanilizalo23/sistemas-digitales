`timescale 1ns/1ps

module demux1to4_tb;

	reg        d;
	reg  [1:0] s;
	wire       y0, y1, y2, y3;

	integer i;

	demux1to4 dut (
		.d(d), .s(s),
		.y0(y0), .y1(y1), .y2(y2), .y3(y3)
	);

	initial begin
		$display("d s | y3 y2 y1 y0");
		for (i = 0; i < 8; i = i + 1) begin
			{d, s} = i;
			#10;
			$display("%b %b |  %b  %b  %b  %b", d, s, y3, y2, y1, y0);
		end
		$stop;
	end

endmodule