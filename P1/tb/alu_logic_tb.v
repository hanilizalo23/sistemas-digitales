//=============================================================
// alu_logic_tb
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/20/2026
//-------------------------------------------------------------
// Testbench for the logic operations of the ALU (control 4 to 9: and, or, not, xor, shift left, shift right)
//
// Same two phase structure as the arithmetic testbench: six selected cases for the waveform, then an exhaustive sweep with a checker
// Operands and results are displayed in binary, which also makes it easy to confirm that the arithmetic flags stay at zero during logic operations
//=============================================================

`timescale 1ns / 1ps

module alu_logic_tb;

	parameter  LENGTH = 5;
	localparam RWIDTH = 2*LENGTH - 2;

	reg  signed [LENGTH-1:0] a, b;
	reg         [3:0]        control;
	wire signed [RWIDTH-1:0] result;
	wire zero, negative, carry, overflow;

	reg signed [RWIDTH-1:0] expected;
	integer i, j, op, errors;

	alu #(.LENGTH(LENGTH)) dut (
		.a(a), 
        .b(b), 
        .control(control), 
        .result(result),
		.zero(zero), 
        .negative(negative), 
        .carry(carry), 
        .overflow(overflow)
	);

	initial begin
		errors = 0;

		// selected cases to show in the waveform
		$display("    a     b  op |   result | ovf car neg zer");

		a = 5'b00011; b = 5'b00101; control = 4'd4; #20; show; // and
		a = 5'b00011; b = 5'b00101; control = 4'd5; #20; show; // or
		a = 5'b00011; b = 5'b00101; control = 4'd6; #20; show; // not a
		a = 5'b00011; b = 5'b00101; control = 4'd7; #20; show; // xor
		a = 5'b00011; b = 5'b00010; control = 4'd8; #20; show; // shift left
		a = 5'b11100; b = 5'b00010; control = 4'd9; #20; show; // shift right

		// checker for all the operations and all the values
		for (op = 4; op <= 9; op = op + 1)
			for (i = -16; i < 16; i = i + 1)
				for (j = -16; j < 16; j = j + 1) begin
					a = i; b = j; control = op; #1;
					case (op)
						4: expected = a & b;
						5: expected = a | b;
						6: expected = ~a;
						7: expected = a ^ b;
						8: expected = a << b[3:0];
						9: expected = a >> b[3:0];
					endcase
					if (result !== expected) begin
						errors = errors + 1;
						if (errors <= 5)
							$display("FAIL op=%0d a=%b b=%b expected=%b got=%b",
							         op, a, b, expected, result);
					end
				end

		$display("errors: %0d", errors);
		$stop;
	end

	task show;
		$display("%b %b  %2d | %b |  %b   %b   %b   %b",
		         a, b, control, result, overflow, carry, negative, zero);
	endtask

endmodule
