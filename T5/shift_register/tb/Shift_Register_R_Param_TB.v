`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// Testbench for a Parametric Right-Shift Register, with high-active synchronous reset
//////////////////////////////////////////////////////////////////////////////////

module Shift_Register_R_Param_TB ( );

localparam width = 4;
reg clk, rst, enable, d;
wire [width-1:0] Q;

Shift_Register_R_Param # (.width (width) )
   UUT (.clk(clk), .rst(rst), .enable(enable),.d(d), .Q(Q) );
    
initial
	begin
		clk     = 1'b0;
		rst     = 1'b0;
		enable	= 1'b1;
		d 		= 1'b0;
		#5 rst	= 1'b1;
		   rst	= 1'b0;
	  #225  rst	= 1'b1;
	    #5	  rst    = 1'b0;
	end

always
	begin
	  #10 clk = ~clk;
	end

always
	begin
	  #20  d = ~d;
	  #20  d = ~d;
	#100 d = ~d;
	#100 d = ~d;
	end	
endmodule
