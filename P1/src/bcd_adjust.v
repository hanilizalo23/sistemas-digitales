//=============================================================
// bcd_adjust
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Double-dabble algorithm
// Checks each 4-bit BCD digit and adds 3 when the digit is 5 or greater, so that the next left shift keeps it a valid decimal digit (0 to 9)
//
// Ports:
//   bcd_in: 12-bit value holding three BCD digits
//   bcd_out: same three digits after the correction
//=============================================================

module bcd_adjust (
	input  wire [11:0] bcd_in, // hundreds, tens, units
	output reg  [11:0] bcd_out
);

	always @(*) begin
		// units
		bcd_out[3:0]  = (bcd_in[3:0]  >= 4'd5) ? bcd_in[3:0]  + 4'd3 : bcd_in[3:0];
		// tens
		bcd_out[7:4]  = (bcd_in[7:4]  >= 4'd5) ? bcd_in[7:4]  + 4'd3 : bcd_in[7:4];
		// hundreds
		bcd_out[11:8] = (bcd_in[11:8] >= 4'd5) ? bcd_in[11:8] + 4'd3 : bcd_in[11:8];
	end

endmodule
