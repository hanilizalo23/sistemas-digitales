`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// Modified by: Nelida Hernandez, 10/18/2026
// Parametric Left-Shift Register, with high-active synchronous reset
//////////////////////////////////////////////////////////////////////////////////

module Shift_Register_L_Param #(parameter width = 9)
    (
    input clk,
    input rst,
    input enable,
    input d,
    output reg [width-1:0] Q
    );

always @(posedge clk)
	begin
		if (rst)
			Q <= {width{1'b0}};
		else
			if (enable)
				Q <= {Q[width-2:0], d};
	end
endmodule
