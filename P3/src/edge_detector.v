//=============================================================
// edge_detector
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// One-cycle pulse on each rising edge of level_in, so holding a button down counts as a single press
//=============================================================

module edge_detector (
	input  wire clk,
	input  wire rst,
	input  wire level_in,
	output wire pulse
);

	wire level_prev;

	// value of level_in one cycle ago
	register_en #(.WIDTH(1)) prev_reg (
		.clk(clk), 
		.rst(rst), 
		.enable(1'b1), 
		.d(level_in), 
		.q(level_prev)
	);

	assign pulse = level_in & ~level_prev;

endmodule
