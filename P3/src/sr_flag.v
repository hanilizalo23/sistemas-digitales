//=============================================================
// sr_flag
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Set/clear flag
// set turns it on and it stays on until clr
// set has priority, so a new event is never lost while clr is held
//=============================================================

module sr_flag (
	input  wire clk,
	input  wire rst,
	input  wire set,
	input  wire clr,
	output reg  q
);

	always @(posedge clk) begin
		if (rst)
			q <= 1'b0;
		else if (set)
			q <= 1'b1;
		else if (clr)
			q <= 1'b0;
	end

endmodule
