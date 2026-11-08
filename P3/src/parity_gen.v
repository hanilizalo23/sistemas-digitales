//=============================================================
// parity_gen
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// XOR of every bit
// Over the data it's the even parity bit to send, over data plus the received parity bit it's 1 only when the parity is wrong
//=============================================================

module parity_gen #(
	parameter WIDTH = 8
) (
	input  wire [WIDTH-1:0] data,
	output wire             parity
);

	assign parity = ^data;

endmodule
