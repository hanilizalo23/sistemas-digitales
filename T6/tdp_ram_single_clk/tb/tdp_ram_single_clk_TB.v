//=============================================================
// tdp_ram_single_clk_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/31/2026
//-------------------------------------------------------------
// Testbench for the true dual port RAM with a single clock, with 8-bit data and 16 addresses
//
// a) Writes every address through port A, one every 2 cycles
// b) Reads every address through port B, one every cycle, so twice as fast as the writes
// c) Writes the same address from both ports in the same clock edge, with different data
//
// Each address i stores A0 + i (A0, A1 ... AF), so a wrong read is easy to spot
// Stimuli change on the falling edge
//=============================================================

`timescale 1ns/1ps
module tdp_ram_single_clk_TB;

	localparam DATA_WIDTH = 8;
	localparam ADDR_WIDTH = 4;

	reg  [DATA_WIDTH-1:0] data_a, data_b;
	reg  [ADDR_WIDTH-1:0] addr_a, addr_b;
	reg                   we_a, we_b, clk;
	wire [DATA_WIDTH-1:0] q_a, q_b;

	integer i;

	true_dual_port_ram_single_clock #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) UUT (
		.data_a(data_a), .data_b(data_b),
		.addr_a(addr_a), .addr_b(addr_b),
		.we_a(we_a),     .we_b(we_b),     .clk(clk),
		.q_a(q_a),       .q_b(q_b)
	);

	// 20 ns clock
	always #10 clk = ~clk;

	initial begin
		clk    = 1'b0;
		we_a   = 1'b0;  we_b   = 1'b0;
		addr_a = 0;     addr_b = 0;
		data_a = 0;     data_b = 0;

		// a) write cycle: one address every 2 clock cycles
		$display("--- a) write all addresses through port A ---");
		for (i = 0; i < 16; i = i + 1) begin
			@(negedge clk);
			we_a = 1'b1; addr_a = i; data_a = 8'hA0 + i;
			@(negedge clk);
		end
		@(negedge clk) we_a = 1'b0;

		// b) read cycle: one address every clock cycle
		$display("--- b) read all addresses through port B ---");
		for (i = 0; i < 16; i = i + 1) begin
			addr_b = i;
			@(negedge clk);
			$display("%4d ns | addr_b = %2d  q_b = %h", $time, addr_b, q_b);
		end

		// c) both ports write address 5 in the same clock edge
		$display("--- c) simultaneous write to the same address ---");
		@(negedge clk);
		we_a = 1'b1; addr_a = 4'd5; data_a = 8'h11;
		we_b = 1'b1; addr_b = 4'd5; data_b = 8'h22;
		@(negedge clk);
		we_a = 1'b0; we_b = 1'b0;
		@(negedge clk);
		$display("%4d ns | address 5 holds q_a = %h  q_b = %h", $time, q_a, q_b);

		$stop;
	end

endmodule
