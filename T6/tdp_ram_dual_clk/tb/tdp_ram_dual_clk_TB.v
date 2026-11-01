//=============================================================
// tdp_ram_dual_clk_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/31/2026
//-------------------------------------------------------------
// Testbench for the true dual port RAM with two clocks, with 8-bit data and 16 addresses
// Adapted from the single clock testbench
//
// Port A runs on clk_a (20 ns) and port B on clk_b (10 ns), so reading through port B is twice as fast as writing through port A
//
// clk_b starts high so its rising edges line up with every rising edge of clk_a: that makes the write collision truly simultaneous
// Stimuli change on the falling edge of clk_b, which never matches an edge of clk_a
//
// a) Writes every address through port A, one per clk_a cycle
// b) Reads every address through port B, one per clk_b cycle
// c) Writes the same address from both ports on a shared edge
//=============================================================

`timescale 1ns/1ps
module tdp_ram_dual_clk_TB;

	localparam DATA_WIDTH = 8;
	localparam ADDR_WIDTH = 4;

	reg  [DATA_WIDTH-1:0] data_a, data_b;
	reg  [ADDR_WIDTH-1:0] addr_a, addr_b;
	reg                   we_a, we_b, clk_a, clk_b;
	wire [DATA_WIDTH-1:0] q_a, q_b;

	integer i;

	true_dual_port_ram_dual_clock #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) UUT (
		.data_a(data_a), .data_b(data_b),
		.addr_a(addr_a), .addr_b(addr_b),
		.we_a(we_a),     .we_b(we_b),
		.clk_a(clk_a),   .clk_b(clk_b),
		.q_a(q_a),       .q_b(q_b)
	);

	// port A clock: 20 ns
	always #10 clk_a = ~clk_a;

	// port B clock: 10 ns, twice as fast
	always #5  clk_b = ~clk_b;

	initial begin
		clk_a  = 1'b0;
		clk_b  = 1'b1;   // rising edges aligned with clk_a
		we_a   = 1'b0;  we_b   = 1'b0;
		addr_a = 0;     addr_b = 0;
		data_a = 0;     data_b = 0;

		// a) write cycle: one address per clk_a cycle
		$display("--- a) write all addresses through port A ---");
		for (i = 0; i < 16; i = i + 1) begin
			@(negedge clk_b);
			we_a = 1'b1; addr_a = i; data_a = 8'hA0 + i;
			@(negedge clk_b);
		end
		@(negedge clk_b) we_a = 1'b0;

		// b) read cycle: one address per clk_b cycle
		$display("--- b) read all addresses through port B ---");
		for (i = 0; i < 16; i = i + 1) begin
			addr_b = i;
			@(negedge clk_b);
			$display("%4d ns | addr_b = %2d  q_b = %h", $time, addr_b, q_b);
		end

		// c) both ports write address 5 on the same rising edge:
		//    wait for a falling edge of clk_a, so the next falling
		//    edge of clk_b sits right before a shared rising edge
		$display("--- c) simultaneous write to the same address ---");
		@(negedge clk_a);
		@(negedge clk_b);
		we_a = 1'b1; addr_a = 4'd5; data_a = 8'h11;
		we_b = 1'b1; addr_b = 4'd5; data_b = 8'h22;
		@(negedge clk_b);
		we_a = 1'b0; we_b = 1'b0;
		$display("%4d ns | right after the write  q_a = %h  q_b = %h", $time, q_a, q_b);
		repeat (2) @(negedge clk_b);
		$display("%4d ns | address 5 holds        q_a = %h  q_b = %h", $time, q_a, q_b);

		$stop;
	end

endmodule
