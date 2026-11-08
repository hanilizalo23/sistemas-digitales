//=============================================================
// shift_register_piso
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Parallel in, serial out shift register
// load copies the whole word, shift moves it one place to the right, so bit 0 leaves first (UART sends the least significant bit first)
// Ones fill in from the top, matching the idle line level
//=============================================================

module shift_register_piso #(
	parameter WIDTH = 8
) (
	input  wire             clk,
	input  wire             rst,
	input  wire             load,
	input  wire             shift,
	input  wire [WIDTH-1:0] d,
	output wire             serial_out
);

	reg [WIDTH-1:0] q;

	always @(posedge clk) begin
		if (rst)
			q <= {WIDTH{1'b1}};
		else if (load)
			q <= d;
		else if (shift)
			q <= {1'b1, q[WIDTH-1:1]};
	end

	assign serial_out = q[0];

endmodule
