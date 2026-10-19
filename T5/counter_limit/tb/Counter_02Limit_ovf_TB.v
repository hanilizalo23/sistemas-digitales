`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// Testbench for the counter from 0 to Limit with overflow flag
////////////////////////////////////////////////////////////////////////////

module Counter_02Limit_ovf_TB(    );
reg rst, clk, enable;
wire [3:0]Q;
wire overflow;

Counter_02Limit_ovf # (.N(4), .Limit(9) )
UUT (.rst(rst), .enable(enable), .clk(clk),
	.Q(Q), .overflow(overflow)    );

initial
    begin
        rst = 1'b1;
        clk = 1'b0;
        enable = 1'b1;
        #5 rst = 1'b0;
    end                                                                                
always
    begin
        #10 clk = ~clk;
    end                                      
endmodule
