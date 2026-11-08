//=============================================================
// uart_rx
//-------------------------------------------------------------
// Nelida Hernandez, ITESO, 11/07/2026
//-------------------------------------------------------------
// UART receiver: start bit, 8 data bits (bit 0 first), even parity bit and one stop bit
//
// The line is synchronized first, since it comes from outside
// While idle, the baud counter is preloaded so its first tick arrives half a bit after the start bit begins, and the next ones one full bit apart: every sample lands mid bit
//
// A 9-bit shift register collects the data and the parity
// At the stop bit, the data goes to the output register, the parity is checked, and rx_flag is set until rx_flag_clr
//
// BIT_CYCLES is the length of one bit in clock cycles: 50 MHz / 9600 baud = 5208
//=============================================================

module uart_rx #(
	parameter BIT_CYCLES = 5208
) (
	input  wire       clk,
	input  wire       rst,
	input  wire       rx,
	input  wire       rx_flag_clr,
	output wire [7:0] rx_data,
	output wire       rx_flag,
	output wire       parity_error
);

	localparam CNT_SIZE  = $clog2(BIT_CYCLES);
	localparam HALF_BIT  = BIT_CYCLES / 2;
	// starting here, the counter wraps after half a bit
	localparam PRELOAD   = BIT_CYCLES - 1 - HALF_BIT;

	wire                rx_sync, idle, shift, store;
	wire                baud_tick, bit_done, parity_bad;
	wire [CNT_SIZE-1:0] baud_count;
	wire [3:0]          bit_count;
	wire [8:0]          sipo_q;

	// the line is idle high, so the synchronizer resets to 1
	synchronizer #(.RESET_VALUE(1)) rx_synchronizer (
		.clk(clk), 
		.rst(rst), 
		.async_in(rx), 
		.sync_out(rx_sync)
	);

	// control
	rx_fsm fsm (
		.clk(clk), 
		.rst(rst), 
		.rx_sync(rx_sync),
		.baud_tick(baud_tick), 
		.bit_done(bit_done),
		.idle(idle), 
		.shift(shift), 
		.store(store)
	);

	// ticks mid bit: preloaded while idle, counts during a frame
	counter_compare #(.SIZE(CNT_SIZE), .MAX_COUNT(BIT_CYCLES-1)) baud_counter (
		.clk(clk), 
		.rst(rst), 
		.enable(~idle), 
		.count_down(1'b0),
		.load(idle), 
		.load_value(PRELOAD[CNT_SIZE-1:0]),
		.count(baud_count), 
		.max_hit(baud_tick)
	);

	// counts the 9 samples (8 data + parity)
	counter_compare #(.SIZE(4), .MAX_COUNT(8)) bit_counter (
		.clk(clk), 
		.rst(rst | idle), 
		.enable(shift), 
		.count_down(1'b0),
		.load(1'b0), 
		.load_value(4'd0),
		.count(bit_count), 
		.max_hit(bit_done)
	);

	// collects the bits, after 9 shifts, [7:0] is the data and [8] the parity bit
	shift_register_sipo #(.WIDTH(9)) sipo (
		.clk(clk), 
		.rst(rst), 
		.shift(shift),
		.serial_in(rx_sync), 
		.q(sipo_q)
	);

	// even parity: data plus parity must hold an even number of ones
	parity_gen #(.WIDTH(9)) parity_check (
		.data(sipo_q), 
		.parity(parity_bad)
	);

	// outputs update only once a full word has arrived
	register_en #(.WIDTH(8)) data_reg (
		.clk(clk), 
		.rst(rst), 
		.enable(store), 
		.d(sipo_q[7:0]), 
		.q(rx_data)
	);

	register_en #(.WIDTH(1)) parity_reg (
		.clk(clk), 
		.rst(rst), 
		.enable(store), 
		.d(parity_bad), 
		.q(parity_error)
	);

	sr_flag flag (
		.clk(clk), 
		.rst(rst), 
		.set(store), 
		.clr(rx_flag_clr), 
		.q(rx_flag)
	);

endmodule
