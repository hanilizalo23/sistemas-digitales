//=============================================================
// mux4
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Parameterized 4 to 1 multiplexer
//=============================================================

module mux4 #(
	parameter WIDTH = 1
) (
	input  wire [1:0]       sel,
	input  wire [WIDTH-1:0] in0,
	input  wire [WIDTH-1:0] in1,
	input  wire [WIDTH-1:0] in2,
	input  wire [WIDTH-1:0] in3,
	output reg  [WIDTH-1:0] out
);

	always @(*) begin
		case (sel)
			2'd0:    out = in0;
			2'd1:    out = in1;
			2'd2:    out = in2;
			default: out = in3;
		endcase
	end

endmodule
