//=============================================================
// rom_sync_TB
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/31/2026
//-------------------------------------------------------------
// Compares the original ROM (case statement) against the array version that synthesizes into an M10K block, reading all 256 addresses from both at the same time
//
// Addresses 0 to 23 are printed as characters, to show the message, and every address is checked for a mismatch between both versions
// Each address is set on a falling edge and read on the next falling edge, after the rising edge that registers the output
//=============================================================

`timescale 1ns/1ps
module rom_sync_TB;

	reg        clk;
	reg  [7:0] address;
	wire [7:0] q_case, q_array;

	// message read back from addresses 1 to 22
	reg [8*22-1:0] text;

	integer i, mismatches;

	// original ROM, written as a case statement
	ROM_Sync rom_case (
		.clk(clk), .ADDRESS(address), .DataOut(q_case)
	);

	// same ROM as a memory array; the simulation runs from tb
	ROM_Sync_array #(.INIT_FILE("../src/rom_sync_init.txt")) rom_array (
		.clk(clk), .ADDRESS(address), .DataOut(q_array)
	);

	// 20 ns clock
	always #10 clk = ~clk;

	initial begin
		clk        = 1'b0;
		address    = 8'd0;
		text       = 0;
		mismatches = 0;

		for (i = 0; i < 256; i = i + 1) begin
			@(negedge clk) address = i;
			@(negedge clk);

			if (i < 24)
				$display("%5d ns | addr %3d | case %h '%c' | array %h '%c'",
				         $time, address, q_case, q_case, q_array, q_array);

			if (i >= 1 && i <= 22)
				text = {text[8*21-1:0], q_array};

			if (q_case !== q_array) begin
				mismatches = mismatches + 1;
				$display("MISMATCH at address %0d: case %h, array %h", i, q_case, q_array);
			end
		end

		$display("message in addresses 1 to 22: \"%s\"", text);
		$display("compared 256 addresses, mismatches = %0d", mismatches);

		$stop;
	end

endmodule
