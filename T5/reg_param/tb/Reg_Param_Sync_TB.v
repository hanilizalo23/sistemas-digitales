//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// Modified by: Nelida Hernandez, 10/18/2026
// Testbench of the Functional model of a parametric register with synchronous active low reset
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps
module Reg_Param_Sync_TB ();

localparam width = 8;

reg rst_n, clk, enable;
reg  [width-1:0] D;
wire [width-1:0]Q;

Reg_Param_Sync   #( .width(width) ) UUT (.rst_n(rst_n), .D(D), .clk(clk), .enable(enable), .Q(Q)     );

initial
	begin
	rst_n 		= 1'b1;
	D 		= 8'h00;
	clk 		= 1'b0;
	enable 	= 1'b1;
#5	rst_n 		= 1'b0;
#10	rst_n 		= 1'b1;
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
      # 840 rst_n  = ~ rst_n;
	 #  15 rst_n  = ~ rst_n;
    end
endmodule
