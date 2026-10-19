`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// Parametric Right-Shift Register, with high-active synchronous reset
//////////////////////////////////////////////////////////////////////////////////

module Shift_Register_R_Param #(parameter width = 9)
    (
    input clk,
    input rst,
    input enable,
    input d,
    output reg [width-1:0] Q
    );
always @(posedge rst, posedge clk)
	begin
		if (rst)
			Q <= {width{1'b0}};
		else
			if (enable)
				Q <= {d,Q[width-1:1]};
	end
endmodule
