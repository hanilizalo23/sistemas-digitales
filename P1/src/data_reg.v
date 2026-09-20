//=============================================================
// data_reg
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Parameterized register with synchronous reset and enable
//
// On every rising clock edge:
//   rst = 1 --> register is cleared
//   enable = 1 --> the register captures d
//   otherwise the register keeps its value
//
// Ports:
//   clk: clock
//   rst: synchronous reset, active high
//   enable: capture enable, active high
//   d: data in
//   q: stored value
//=============================================================

module data_reg #(
	parameter WIDTH = 8
) (
	input  wire             clk,
	input  wire             rst,
	input  wire             enable,
	input  wire [WIDTH-1:0] d,
	output reg  [WIDTH-1:0] q
);

	always @(posedge clk) begin // updates every time we have a rising edge on the clk, meaning it would remember d
		if (rst)
			q <= {WIDTH{1'b0}}; // <= non-blocking --> so all flip-flops update together on the edge
		else if (enable) // no else q <= q because the idea is to actually remember (no combinational circuit, no latch)
			q <= d;
	end

endmodule
