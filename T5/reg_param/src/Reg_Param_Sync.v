//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// Modified by: Nelida Hernandez, 10/18/2026
// Functional model of a parametric register with synchronous active low reset
//////////////////////////////////////////////////////////////////////////////////

module Reg_Param_Sync  #(parameter width=4)(
    input rst_n,
    input [width-1:0]D,
    input clk,
    input enable,
    output reg [width-1:0]Q
    );

always @(posedge clk)
    begin
        if (!rst_n)
            Q <= {width{1'b0}};
        else
            if (enable)
                Q <= D;
            else
                Q <= Q;
    end
endmodule
