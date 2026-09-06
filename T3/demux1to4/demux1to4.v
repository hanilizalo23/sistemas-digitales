module demux1to4 (
	input  wire       d,
	input  wire [1:0] s,
	
	output wire       y0,
	output wire       y1,
	output wire       y2,
	output wire       y3
);

assign y0 = d & ~s[1] & ~s[0];
assign y1 = d & ~s[1] &  s[0];
assign y2 = d &  s[1] & ~s[0];
assign y3 = d &  s[1] &  s[0];

endmodule
