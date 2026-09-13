module array_multiplier #(
	parameter WIDTH = 4
) (
	input  wire [WIDTH-1:0]   a, // multiplier --> its bits gate each row
	input  wire [WIDTH-1:0]   b, // multiplicand --> copied into each row
	output wire [2*WIDTH-1:0] y
);

	// each row passes its leftover to the next one
	wire [WIDTH-1:0] sum_so_far [0:WIDTH-1];

	wire [WIDTH-1:0] first_row;

	// partial product of row 0, one AND gate per bit of b
	genvar i, j;
	generate
		for (j = 0; j < WIDTH; j = j + 1) begin : first_and
			assign first_row[j] = a[0] & b[j];
		end
	endgenerate

	// row 0 needs no adder because nothing has been accumulated yet
	assign y[0]          = first_row[0];
	assign sum_so_far[0] = {1'b0, first_row[WIDTH-1:1]};

	// remaining rows, AND gates plus one adder each
	generate
		for (i = 1; i < WIDTH; i = i + 1) begin : rows

			wire [WIDTH-1:0] row_product;
			wire [WIDTH-1:0] row_sum;
			wire             row_cout;

			// partial product of this row
			for (j = 0; j < WIDTH; j = j + 1) begin : row_and
				assign row_product[j] = a[i] & b[j];
			end

			// add it to what came from the row above
			adder_nbit #(.WIDTH(WIDTH)) row_adder (
				.a    (sum_so_far[i-1]),
				.b    (row_product),
				.sum  (row_sum),
				.cout (row_cout)
			);

			// lowest bit is final, shift the rest down for the next row
			assign y[i]          = row_sum[0];
			assign sum_so_far[i] = {row_cout, row_sum[WIDTH-1:1]};

		end
	endgenerate

	// nothing left to add, the accumulator is the top half
	assign y[2*WIDTH-1 : WIDTH] = sum_so_far[WIDTH-1];

endmodule