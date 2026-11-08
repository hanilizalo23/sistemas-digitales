//=============================================================
// counter_compare
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// Parameterized counter with compare
// Counts up or down while enabled and wraps at the limit, max_hit marks the cycle of the wrap
// load copies load_value, with priority reset > load > count
//=============================================================

module counter_compare #(
	parameter SIZE        = 4, // width of the counter in bits
	parameter MAX_COUNT   = 9, // highest value before wrapping
	parameter RESET_VALUE = 0  // value loaded on reset
) (
	input  wire            clk,
	input  wire            rst,
	input  wire            enable,
	input  wire            count_down,
	input  wire            load,
	input  wire [SIZE-1:0] load_value,
	output reg  [SIZE-1:0] count,
	output wire            max_hit
);

	// high for the single cycle where the counter wraps
	assign max_hit = enable & (count_down ? (count == {SIZE{1'b0}})
	                                      : (count == MAX_COUNT[SIZE-1:0]));

	always @(posedge clk) begin
		if (rst)
			count <= RESET_VALUE[SIZE-1:0];
		else if (load)
			count <= load_value;
		else if (enable) begin
			if (count_down)
				count <= (count == {SIZE{1'b0}}) ? MAX_COUNT[SIZE-1:0]
				                                 : count - 1'b1;
			else
				count <= (count == MAX_COUNT[SIZE-1:0]) ? {SIZE{1'b0}}
				                                        : count + 1'b1;
		end
	end

endmodule
