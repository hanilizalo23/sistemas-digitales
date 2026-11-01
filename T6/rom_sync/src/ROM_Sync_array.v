//=============================================================
// ROM_Sync_array
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 10/31/2026
//-------------------------------------------------------------
// Same ROM as ROM_Sync (same ports and contents), written as a memory array loaded from a file instead of a case statement
//
// Quartus turned the case version into logic and never treated it as a memory, so neither romstyle nor the minimum size option had anything to act on
// An initialized array is recognized as a memory from the start, and romstyle places it in an M10K
//
// Contents: address 0 and 23 to 255 hold '@' (40h), and addresses 1 to 22 hold "Hello welcome to ITESO"
//=============================================================

(* romstyle = "M10K" *)
module ROM_Sync_array #(
	parameter INIT_FILE = "src/rom_sync_init.txt"
) (
	input  wire       clk,
	input  wire [7:0] ADDRESS,
	output reg  [7:0] DataOut
);

	(* romstyle = "M10K" *) reg [7:0] rom [0:255];

	initial
		$readmemh(INIT_FILE, rom);

	always @(posedge clk)
		DataOut <= rom[ADDRESS];

endmodule
