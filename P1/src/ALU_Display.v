//=============================================================
// ALU_Display
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 9/19/2026
//-------------------------------------------------------------
// Top level of the ALU
//
// Both operands share the same five switches: SW[9:5] holds whichever value is being loaded, and KEY0/KEY1 decide where it's stored
// The operation is selected live on SW[4:1] and the result is captured with KEY2
// Holding KEY0 or KEY1 makes the displays show that stored operand instead of the result, so what is loaded can be checked
//
// Arithmetic results (control 0 to 3) are shown in signed decimal, logic results (control 4 to 9) in hexadecimal
// The binary to decimal converter is shared in time between the operands and the result
//
// Board mapping:
//   SW[9:5]     operand value to load
//   SW[4:1]     operation select
//   SW[0]       reset, active high
//   KEY0        load A/show A
//   KEY1        load B/show B
//   KEY2        load result
//   HEX2..HEX0  value being shown
//   HEX3        minus sign
//   HEX4        selected operation
//   LEDR[3:0]   overflow, carry, negative, zero
//=============================================================

module ALU_Display #(
	parameter LENGTH = 5
) (
	input  wire        CLOCK_50,
	input  wire [9:0]  SW,
	input  wire [2:0]  KEY,
	output wire [6:0]  HEX0,
	output wire [6:0]  HEX1,
	output wire [6:0]  HEX2,
	output wire [6:0]  HEX3,
	output wire [6:0]  HEX4,
	output wire [3:0]  LEDR
);

	localparam RWIDTH = 2*LENGTH - 2;  // 8 bits when LENGTH = 5
	localparam SEG_OFF   = 7'b1111111; // all segments off, active low
	localparam SEG_MINUS = 7'b0111111; // only segment g on (-)

	// control signals
	wire clk = CLOCK_50;
	wire rst = SW[0];

	// push buttons are active low
	wire load_a      = ~KEY[0];
	wire load_b      = ~KEY[1];
	wire load_result = ~KEY[2];

	wire [3:0] control = SW[4:1];

	// input registers
	wire [LENGTH-1:0] a_stored;
	wire [LENGTH-1:0] b_stored;

	data_reg #(.WIDTH(LENGTH)) reg_a (
		.clk(clk), 
		.rst(rst), 
		.enable(load_a),
		.d(SW[9:5]), 
		.q(a_stored)
	);

	data_reg #(.WIDTH(LENGTH)) reg_b (
		.clk(clk), 
		.rst(rst), 
		.enable(load_b),
		.d(SW[9:5]), 
		.q(b_stored)
	);

	// alu
	wire [RWIDTH-1:0] alu_result;
	wire alu_zero, alu_negative, alu_carry, alu_overflow;

	alu #(.LENGTH(LENGTH)) alu_unit (
		.a(a_stored), 
		.b(b_stored), 
		.control(control),
		.result(alu_result),
		.zero(alu_zero), 
		.negative(alu_negative),
		.carry(alu_carry), 
		.overflow(alu_overflow)
	);

	// output registers
	wire [RWIDTH-1:0] result_stored;
	wire [3:0]        flags_stored;

	data_reg #(.WIDTH(RWIDTH)) reg_result (
		.clk(clk), 
		.rst(rst), 
		.enable(load_result),
		.d(alu_result), 
		.q(result_stored)
	);

	data_reg #(.WIDTH(4)) reg_flags (
		.clk(clk), 
		.rst(rst), 
		.enable(load_result),
		.d({alu_overflow, alu_carry, alu_negative, alu_zero}),
		.q(flags_stored)
	);

	// what the displays are showing
	// holding a load button shows that operand instead of the result
	wire show_operand = load_a | load_b;
	wire [LENGTH-1:0] operand_shown = load_a ? a_stored : b_stored;

	// operand widened to the result width so the converter can take it
	wire signed [RWIDTH-1:0] operand_ext = {{(RWIDTH-LENGTH){operand_shown[LENGTH-1]}}, operand_shown};

	// decimal conversion, shared between operands and result
	wire signed [RWIDTH-1:0] to_decimal = show_operand ? operand_ext : result_stored;

	wire [11:0] bcd_digits;
	wire        value_is_neg;

	signed_to_bcd decimal_unit (
		.value(to_decimal),
		.bcd(bcd_digits),
		.is_neg(value_is_neg)
	);

	// display format
	// controls 0 to 3 are arithmetic and show decimal, the rest show the value in hexadecimal
	// operands are always shown in decimal
	wire is_arith    = (control <= 4'd3);
	wire use_decimal = show_operand | is_arith;

	wire [3:0] digit0 = use_decimal ? bcd_digits[3:0]  : result_stored[3:0];
	wire [3:0] digit1 = use_decimal ? bcd_digits[7:4]  : result_stored[7:4];
	wire [3:0] digit2 = use_decimal ? bcd_digits[11:8] : 4'd0;

	// seven segment
	hex7seg disp0 (.value(digit0), .seg(HEX0));
	hex7seg disp1 (.value(digit1), .seg(HEX1));
	hex7seg disp2 (.value(digit2), .seg(HEX2));

	// minus sign, only matters when the value is decimal
	wire show_minus = use_decimal & value_is_neg;
	assign HEX3 = show_minus ? SEG_MINUS : SEG_OFF;

	// selected operation, always visible
	wire [6:0] seg_control;
	hex7seg disp_control (.value(control), .seg(seg_control));
	
	assign HEX4 = seg_control;

	// flags
	assign LEDR[3:0] = flags_stored;

endmodule
