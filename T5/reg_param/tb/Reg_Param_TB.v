//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO 
// Engineer: Cuauhtemoc Aguilera
// Testbench of the Functional model of a parametric register with asynchronous reset
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps
module Reg_Param_TB ();

localparam width = 8;

reg rst, clk, enable;
reg  [width-1:0] D;
wire [width-1:0]Q;

Reg_Param   #( .width(width) ) UUT (.rst(rst), .D(D), .clk(clk), .enable(enable), .Q(Q)     );

initial
	begin
	rst 		= 1'b0;
	D 		= 8'h00;
	clk 		= 1'b0;
	enable 	= 1'b1;
#5	rst 		= 1'b1;
#3	rst 		= 1'b0;
	end

always
    begin
      # 10 clk = ~ clk;
    end    

always
    begin
      # 20 D = D + 1'b1;
    end    

always
    begin
      # 800 enable  = ~ enable;
      # 80 enable  = ~ enable;
    end

always
    begin
      # 840 rst  = ~ rst;
	 #   5 rst  = ~ rst;
    end
endmodule
