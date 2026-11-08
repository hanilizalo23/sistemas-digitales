//=============================================================
// uart_tx
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// UART transmitter: start bit, 8 data bits (bit 0 first), even parity bit and one stop bit
//
// While idle, the data and its parity are copied every cycle, so they freeze at the value present when tx_send arrives
// A baud counter marks the end of each bit, and the FSM picks what the line carries through a 4 to 1 mux
// The line goes through a final register so it never glitches
//
// BIT_CYCLES is the length of one bit in clock cycles: 50 MHz / 9600 baud = 5208
//=============================================================

module uart_tx #(
	parameter BIT_CYCLES = 5208
) (
	input  wire       clk,
	input  wire       rst,
	input  wire       tx_send,
	input  wire [7:0] tx_data,
	output wire       tx
);

	localparam CNT_SIZE = $clog2(BIT_CYCLES);

	wire                idle, shift, baud_tick, bit_done;
	wire                piso_out, parity, parity_q, tx_bit;
	wire [1:0]          tx_sel;
	wire [CNT_SIZE-1:0] baud_count;
	wire [2:0]          bit_count;

	// control
	tx_fsm fsm (
		.clk(clk), 
		.rst(rst), 
		.tx_send(tx_send),
		.baud_tick(baud_tick), 
		.bit_done(bit_done),
		.idle(idle), 
		.shift(shift), 
		.tx_sel(tx_sel)
	);

	// one tick per bit time, cleared while idle so each frame
	// starts with a full bit
	counter_compare #(.SIZE(CNT_SIZE), .MAX_COUNT(BIT_CYCLES-1)) baud_counter (
		.clk(clk), 
		.rst(rst | idle), 
		.enable(~idle), 
		.count_down(1'b0),
		.load(1'b0), 
		.load_value({CNT_SIZE{1'b0}}),
		.count(baud_count), 
		.max_hit(baud_tick)
	);

	// counts the 8 data bits, bit_done marks the last one
	counter_compare #(.SIZE(3), .MAX_COUNT(7)) bit_counter (
		.clk(clk), 
		.rst(rst | idle), 
		.enable(shift), 
		.count_down(1'b0),
		.load(1'b0), 
		.load_value(3'd0),
		.count(bit_count), 
		.max_hit(bit_done)
	);

	// data register: loaded while idle, shifted during DATA
	shift_register_piso #(.WIDTH(8)) piso (
		.clk(clk), 
		.rst(rst), 
		.load(idle), 
		.shift(shift),
		.d(tx_data), 
		.serial_out(piso_out)
	);

	// even parity of the data, held during the frame
	parity_gen #(.WIDTH(8)) parity_unit (
		.data(tx_data), 
		.parity(parity)
	);

	register_en #(.WIDTH(1)) parity_reg (
		.clk(clk), 
		.rst(rst), 
		.enable(idle), 
		.d(parity), 
		.q(parity_q)
	);

	// line value: 1 (idle, stop), 0 (start), data bit, parity bit
	mux4 #(.WIDTH(1)) tx_mux (
		.sel(tx_sel), 
		.in0(1'b1), 
		.in1(1'b0),
		.in2(piso_out), 
		.in3(parity_q), 
		.out(tx_bit)
	);

	// registered output, idle high after reset
	register_en #(.WIDTH(1), .RESET_VALUE(1)) tx_reg (
		.clk(clk), 
		.rst(rst), 
		.enable(1'b1), 
		.d(tx_bit), 
		.q(tx)
	);

endmodule
