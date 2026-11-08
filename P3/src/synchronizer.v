//=============================================================
// synchronizer
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Two flip-flops in a row for a signal that isn't related to the clock (the rx line, or a push button)
// The second stage gives the first one a full cycle to settle, which keeps a metastable value from reaching the rest of the design
// RESET_VALUE should match the idle level of the input
//=============================================================

module synchronizer #(
	parameter RESET_VALUE = 0
) (
	input  wire clk,
	input  wire rst,
	input  wire async_in,
	output wire sync_out
);

	wire stage1;

	register_en #(.WIDTH(1), .RESET_VALUE(RESET_VALUE)) ff1 (
		.clk(clk), 
		.rst(rst), 
		.enable(1'b1), 
		.d(async_in), 
		.q(stage1)
	);

	register_en #(.WIDTH(1), .RESET_VALUE(RESET_VALUE)) ff2 (
		.clk(clk), 
		.rst(rst), 
		.enable(1'b1), 
		.d(stage1), 
		.q(sync_out)
	);

endmodule
