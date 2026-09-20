//=============================================================
// signed_to_bcd_tb
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/20/2026
//-------------------------------------------------------------
// Testbench for the binary to decimal converter
//
// It applies a few selected values for the waveform and then sweeps the whole 8-bit signed range, rebuilding the number from the three BCD digits and the sign flag to compare it against the input
// Results are reported as separate 4-bit groups (hundreds, tens and units), which is the BCD representation the display receives
//=============================================================

`timescale 1ns/1ps

module signed_to_bcd_tb;

	reg signed [7:0] value;
	wire      [11:0] bcd;
	wire             is_neg;

	// the three digits split out, so the waveform shows them as separate 4-bit groups
	wire [3:0] hundreds = bcd[11:8];
	wire [3:0] tens     = bcd[7:4];
	wire [3:0] units    = bcd[3:0];

	integer i, errors, rebuilt;

	signed_to_bcd dut (
        .value(value), 
        .bcd(bcd), 
        .is_neg(is_neg));

	initial begin
		errors = 0;

		// selected cases to show in the waveform
		$display("value | sign | hund tens unit");

		value =    0; #20; show;
		value =    7; #20; show;
		value =   47; #20; show;
		value =  127; #20; show;
		value =  -47; #20; show;
		value = -128; #20; show;

		// sweep the whole signed range, rebuilding the number from the digits and comparing it back
		for (i = -128; i < 128; i = i + 1) begin
			value = i; #1;
			rebuilt = hundreds*100 + tens*10 + units;
			if (is_neg) rebuilt = -rebuilt;
			if (rebuilt !== i) begin
				errors = errors + 1;
				if (errors <= 5)
					$display("FAIL value=%0d rebuilt=%0d", i, rebuilt);
			end
		end

		$display("errors: %0d", errors);
		$stop;
	end

	task show;
		$display("%5d |   %b  | %b %b %b",
		         value, is_neg, hundreds, tens, units);
	endtask

endmodule
