//=============================================================
// alu_arith_tb
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/20/2026
//-------------------------------------------------------------
// Testbench for the arithmetic operations of the ALU (control 0 to 3: add, subtract, negate b, multiply)
//
// It runs in two phases: the first one applies six selected cases with a 20 ns gap between them, so the waveform stays readable and covers every flag
// The second one sweeps all operand pairs for the four operations and compares the result against a reference with Verilog operators, reporting how many mismatches were found
// Operands and results are displayed in signed decimal
//=============================================================

`timescale 1ns/1ps

module alu_arith_tb;

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
        $display("   a    b  op | result | ovf car neg zer");

		a =  3; b =   5; control = 4'd0; #20; show; // add
		a =  3; b =   5; control = 4'd1; #20; show; // subtract
		a =  0; b = -16; control = 4'd2; #20; show; // negate b
		a = -3; b =   5; control = 4'd3; #20; show; // multiply
		a =  7; b =   7; control = 4'd1; #20; show; // zero flag
		a =-16; b = -16; control = 4'd3; #20; show; // multiply overflow

		// checker for all the operations and all the values
		for (op = 0; op <= 3; op = op + 1)
			for (i = -16; i < 16; i = i + 1)
				for (j = -16; j < 16; j = j + 1) begin
					a = i; b = j; control = op; #1;
					case (op)
						0: expected = i + j;
						1: expected = i - j;
						2: expected = -j;
						3: expected = i * j;
					endcase
					if (result !== expected) begin
						errors = errors + 1;
						if (errors <= 5)
							$display("FAIL op=%0d a=%0d b=%0d expected=%0d got=%0d",
							         op, i, j, expected, result);
					end
				end

		$display("errors: %0d", errors);
		$stop;
	end

	task show;
		$display("%4d %4d  %2d | %6d |  %b   %b   %b   %b",
		         a, b, control, result, overflow, carry, negative, zero);
	endtask

endmodule
