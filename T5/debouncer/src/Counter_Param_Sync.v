`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// Modified by: Nelida Hernandez, 10/18/2026
// Module 2^n Counter, with synchronous reset
//////////////////////////////////////////////////////////////////////////////////

module Counter_Param_Sync
 # (parameter n = 4)
(    input clk,
    input rst,
    input enable,
    output reg [n-1:0] Q  );

 always @(posedge clk)
    begin
        if (rst)
            Q <= {n{1'b0}};
        else
            if (enable)
                Q <= Q + 1'b1;
            else
                Q <= Q;
    end
endmodule
