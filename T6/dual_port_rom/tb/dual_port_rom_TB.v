//=============================================================
// dual_port_rom_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/31/2026
//-------------------------------------------------------------
// Testbench for the dual address port ROM, loaded with an ASCII message from rom_init.txt (32 addresses)
//
// Port A reads the addresses going up (0 to 31) while port B reads them going down (31 to 0), at the same time
// Port A should spell the message and port B the same message backwards
// Each read is printed as a character, and both full strings are printed at the end
//
// The ROM output has one cycle of latency: an address set on a falling edge is read on the next rising edge, so it's printed on the falling edge after that
//=============================================================

`timescale 1ns/1ps
module dual_port_rom_TB;

	localparam DATA_WIDTH = 8;
	localparam ADDR_WIDTH = 5;
	localparam DEPTH      = 2**ADDR_WIDTH;

	reg  [ADDR_WIDTH-1:0] addr_a, addr_b;
	reg                   clk;
	wire [DATA_WIDTH-1:0] q_a, q_b;

	// the two strings read back, one character per byte
	reg [8*DEPTH-1:0] text_a, text_b;

	integer i;

	// the simulation runs from the tb folder
	dual_port_rom #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
	                .INIT_FILE("../src/rom_init.txt")) UUT (
		.addr_a(addr_a), .addr_b(addr_b), .clk(clk),
		.q_a(q_a),       .q_b(q_b)
	);

	// 20 ns clock
	always #10 clk = ~clk;

	initial begin
		clk    = 1'b0;
		addr_a = 0;
		addr_b = DEPTH - 1;
		text_a = 0;
		text_b = 0;

		@(negedge clk);
		for (i = 0; i < DEPTH; i = i + 1) begin
			addr_a = i;              // going up
			addr_b = DEPTH - 1 - i;  // going down
			@(negedge clk);
			$display("%4d ns | A: addr %2d = %h '%c' | B: addr %2d = %h '%c'",
			         $time, addr_a, q_a, q_a, addr_b, q_b, q_b);
			// append each character to its string
			text_a = {text_a[8*DEPTH-9:0], q_a};
			text_b = {text_b[8*DEPTH-9:0], q_b};
		end

		$display("port A, ascending : \"%s\"", text_a);
		$display("port B, descending: \"%s\"", text_b);

		$stop;
	end

endmodule
