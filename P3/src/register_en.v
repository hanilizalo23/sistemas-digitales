//=============================================================
// register_en
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Parameterized register with enable and synchronous reset
// RESET_VALUE sets the value after reset, so a serial line can reset to its idle level (1)
//=============================================================

module register_en #(
	parameter WIDTH       = 8,
	parameter RESET_VALUE = 0
) (
	input  wire             clk,
	input  wire             rst,
	input  wire             enable,
	input  wire [WIDTH-1:0] d,
	output reg  [WIDTH-1:0] q
);

	always @(posedge clk) begin
		if (rst)
			q <= RESET_VALUE[WIDTH-1:0];
		else if (enable)
			q <= d;
	end

endmodule
