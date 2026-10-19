`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// ff_d with asynchronous rst, and enable.
//////////////////////////////////////////////////////////////////////////////////
module ff_d_e (
input clk, 
input rst,
input d,
input enable,
output nq,
output reg q );

assign nq = ~q;

always @ (posedge rst, posedge clk)
	begin 
		if (rst)
			q <= 1'b0;
		else
			if (enable)
				q <= d;
			else 
				q <= q;
	end 
endmodule
