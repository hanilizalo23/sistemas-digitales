//=============================================================
// counter_compare
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/10/2026
//-------------------------------------------------------------
// Parameterized counter with compare, used as the single building block for the whole time chain
//
// Counts up or down while enabled, wrapping at MAX_COUNT when counting up and at zero when counting down
// The max_hit output marks the cycle where the wrap happens, so it can enable the next stage of the chain
//
// Ports:
//   clk        : clock
//   rst        : synchronous reset, active high
//   enable     : counts only when high
//   count_down : 0 counts up, 1 counts down
//   load       : loads load_value instead of counting
//   load_value : preset value for timer mode
//   count      : current value
//   max_hit    : high when this stage wraps around
//=============================================================

module counter_compare #(
	parameter SIZE      	 = 4, // width of the counter in bits
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

	// max_hit tells the next stage to advance
	// it includes enable so it lasts a single cycle, without it, the signal would stay high while parked at the limit
	// counting down, the limit is zero instead of MAX_COUNT
	assign max_hit = enable & (count_down ? (count == {SIZE{1'b0}}) : (count == MAX_COUNT[SIZE-1:0]));

	always @(posedge clk) begin
		if (rst) 				     // reset wins over everything else
			count <= RESET_VALUE[SIZE-1:0];
		else if (load)            // load wins over counting, used to preset the timer
			count <= load_value;
		else if (enable) begin    // only move when enabled, so a paused stage holds its value
			if (count_down)
				count <= (count == {SIZE{1'b0}}) ? MAX_COUNT[SIZE-1:0] : count - 1'b1; // wrap back to the top after reaching zero
			else
				count <= (count == MAX_COUNT[SIZE-1:0]) ? {SIZE{1'b0}} : count + 1'b1; // wrap back to zero after reaching the limit
		end
	end

endmodule
