//=============================================================
// debouncer
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/18/2026
//-------------------------------------------------------------
// Structural debouncer: the output follows the input only after it has been stable for 2^(N-1) clock cycles
//
// ff1 and ff2 synchronize the input
// Their XOR detects a change and clears the counter, so a bouncing input keeps it at zero
// When the top bit of the counter sets, the counter stops and ff3 is enabled to copy the stable value to the output
//
// Ports:
//   clk        : clock
//   reset_n    : asynchronous reset, active low
//   button_in  : raw input, may bounce
//   button_out : debounced output
//=============================================================

module debouncer #(
	parameter N = 21    // 2^20 cycles, about 21 ms at 50 MHz
) (
	input  wire clk,
	input  wire reset_n,
	input  wire button_in,
	output wire button_out
);

	wire         rst;       // active high reset for the flip-flops
	wire         q1, q2;    // synchronizer stages
	wire         changed;   // input changed between the two stages
	wire         cnt_rst;   // clears the counter
	wire         cnt_en;    // counter runs until its top bit sets
	wire [N-1:0] count;

	// ff_d_e resets active high, the FPGA reset is active low
	assign rst = ~reset_n;

	// two stage synchronizer
	ff_d_e ff1 (
	.clk(clk), 
	.rst(rst), 
	.d(button_in), 
	.enable(1'b1), 
	.nq(), 
	.q(q1)
	);
	
	ff_d_e ff2 (
	.clk(clk), 
	.rst(rst), 
	.d(q1),        
	.enable(1'b1), 
	.nq(), 
	.q(q2)
	);

	// clear the counter on every change, and on the global reset, which the figure omits but the counter needs to start defined
	assign changed = q1 ^ q2;
	assign cnt_rst = changed | rst;

	// count while the top bit is clear, then hold
	assign cnt_en = ~count[N-1];

	Counter_Param_Sync #(.n(N)) counter (
		.clk(clk), 
		.rst(cnt_rst), 
		.enable(cnt_en), 
		.Q(count)
	);

	// output stage: copies the input only once it is stable
	ff_d_e ff3 (
	.clk(clk), 
	.rst(rst), 
	.d(q2), 
	.enable(count[N-1]), 
	.nq(), 
	.q(button_out)
	);

endmodule
