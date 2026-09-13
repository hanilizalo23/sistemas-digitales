module gray2bin #(
	parameter WIDTH = 4
) (
	input  wire [WIDTH-1:0] g,
	output wire [WIDTH-1:0] b
);

	// MSB passes directly
	assign b[WIDTH-1] = g[WIDTH-1];

	// xor chain --> each bit uses the previous output bit
	genvar i;
	generate
		for (i = WIDTH-2; i >= 0; i = i - 1) begin : xor_gray2bin
			assign b[i] = b[i+1] ^ g[i];
		end
	endgenerate

endmodule
