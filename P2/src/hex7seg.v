//=============================================================
// hex7seg
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Seven segment decoder, one hexadecimal digit (0 to F)
// Segments are active low on the board, so a 0 turns a segment on
//
// The blank input turns the whole digit off, which is used to hide leading zeros while the count has not reached them
//
// Ports:
//   value: 4-bit digit to display
//   blank: 1 turns every segment off, value is ignored
//   seg: segment outputs, bit 0 is segment a, bit 6 is g
//=============================================================

module hex7seg (
	input  wire [3:0] value,
	input  wire       blank,
	output reg  [6:0] seg
);

	always @(*) begin
		if (blank)
			seg = 7'b1111111; // all segments off
		else
			case (value)
				            // gfedcba
				4'h0: seg = 7'b1000000;
				4'h1: seg = 7'b1111001;
				4'h2: seg = 7'b0100100;
				4'h3: seg = 7'b0110000;
				4'h4: seg = 7'b0011001;
				4'h5: seg = 7'b0010010;
				4'h6: seg = 7'b0000010;
				4'h7: seg = 7'b1111000;
				4'h8: seg = 7'b0000000;
				4'h9: seg = 7'b0010000;
				4'hA: seg = 7'b0001000;
				4'hB: seg = 7'b0000011;
				4'hC: seg = 7'b1000110;
				4'hD: seg = 7'b0100001;
				4'hE: seg = 7'b0000110;
				4'hF: seg = 7'b0001110;
				default: seg = 7'b1111111; // all off
			endcase
	end

endmodule
