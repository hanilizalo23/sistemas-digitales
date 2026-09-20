//=============================================================
// signed_to_bcd
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Converts an 8-bit two's complement number (-128 to +127) into three BCD digits plus a sign flag
//
// The number is first turned into its magnitude, because the double-dabble algorithm only works on unsigned values
// Seven bcd_adjust stages then shift the magnitude in, one bit at a time, correcting the digits between shifts
//
// Ports:
//   value: 8-bit signed number to display
//   bcd: 12 bits, three BCD digits (hundreds, tens, units)
//   is_neg: 1 when the input is negative, drives the minus sign
//=============================================================

module signed_to_bcd (
	input  wire signed [7:0]  value,
	output wire        [11:0] bcd,
	output wire               is_neg
);

	// the sign is the MSB
	assign is_neg = value[7];

	// magnitude: negate when negative, pass through when positive
	wire [7:0] magnitude = is_neg ? (~value + 8'd1) : value;

	// output of each correction stage
	wire [11:0] stage0, stage1, stage2, stage3, stage4, stage5, stage6;

	// starts empty
	wire [11:0] start = 12'd0;

	// shift one bit in, most significant first, then correct
	bcd_adjust adjust0 (.bcd_in({start[10:0],  magnitude[7]}), .bcd_out(stage0));
	bcd_adjust adjust1 (.bcd_in({stage0[10:0], magnitude[6]}), .bcd_out(stage1));
	bcd_adjust adjust2 (.bcd_in({stage1[10:0], magnitude[5]}), .bcd_out(stage2));
	bcd_adjust adjust3 (.bcd_in({stage2[10:0], magnitude[4]}), .bcd_out(stage3));
	bcd_adjust adjust4 (.bcd_in({stage3[10:0], magnitude[3]}), .bcd_out(stage4));
	bcd_adjust adjust5 (.bcd_in({stage4[10:0], magnitude[2]}), .bcd_out(stage5));
	bcd_adjust adjust6 (.bcd_in({stage5[10:0], magnitude[1]}), .bcd_out(stage6));

	// last shift doesn't need correction
	assign bcd = {stage6[10:0], magnitude[0]};

endmodule
