module mux6to1 (
	input  wire       d0,
	input  wire       d1,
	input  wire       d2,
	input  wire       d3,
	input  wire       d4,
	input  wire       d5,
	input  wire [2:0] s,
	
	output wire       y
);

	// level 1 --> controlled by s[0]
	wire pair_01;
	wire pair_23;
	wire pair_45;
	wire pair_unused;

	mux2to1 #(.WIDTH(1)) pick_d0_d1 ( .d0(d0), .d1(d1), .s(s[0]), .y(pair_01) );
	mux2to1 #(.WIDTH(1)) pick_d2_d3 ( .d0(d2), .d1(d3), .s(s[0]), .y(pair_23) );
	mux2to1 #(.WIDTH(1)) pick_d4_d5 ( .d0(d4), .d1(d5), .s(s[0]), .y(pair_45) );
	mux2to1 #(.WIDTH(1)) pick_unused ( .d0(1'b0), .d1(1'b0), .s(s[0]), .y(pair_unused) );

	
	// level 2 --> controlled by s[1]
	wire group_low;
	wire group_high;

	mux2to1 #(.WIDTH(1)) pick_low_group ( .d0(pair_01), .d1(pair_23), .s(s[1]), .y(group_low) );
	mux2to1 #(.WIDTH(1)) pick_high_group ( .d0(pair_45), .d1(pair_unused), .s(s[1]), .y(group_high) );

	
	// level 3 --> controlled by s[2]
	mux2to1 #(.WIDTH(1)) pick_final ( .d0(group_low), .d1(group_high), .s(s[2]), .y(y) );

endmodule
