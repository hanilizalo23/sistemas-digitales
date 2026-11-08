//=============================================================
// shift_register_sipo
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Serial in, parallel out shift register
// Each shift pushes serial_in into the top bit and moves the rest down, so the first bit received ends up in bit 0
//=============================================================

module shift_register_sipo #(
	parameter WIDTH = 9
) (
	input  wire             clk,
	input  wire             rst,
	input  wire             shift,
	input  wire             serial_in,
	output reg  [WIDTH-1:0] q
);

	always @(posedge clk) begin
		if (rst)
			q <= {WIDTH{1'b0}};
		else if (shift)
			q <= {serial_in, q[WIDTH-1:1]};
	end

endmodule
