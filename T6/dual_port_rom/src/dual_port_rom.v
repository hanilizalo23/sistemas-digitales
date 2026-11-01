// Quartus II Verilog Template
// Dual Port ROM
// Modified by: Nelida Hernandez, 10/31/2026
// - memory declared as reg instead of logic, so it's plain Verilog
// - init file read in hexadecimal, from the path in INIT_FILE
// - 32 addresses, enough for the init message

module dual_port_rom
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=5,
  parameter INIT_FILE="src/rom_init.txt")
(
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

	// Declare the ROM variable
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	// Initialize the ROM with $readmemh from the file in INIT_FILE
	// Without this file, this design will not compile
	initial
	begin
		$readmemh(INIT_FILE, rom);
	end

	always @ (posedge clk)
	begin
		q_a <= rom[addr_a];
		q_b <= rom[addr_b];
	end

endmodule
