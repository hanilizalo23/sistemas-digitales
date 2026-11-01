
// force the inferred ROM into an M10K memory block, and allow ROM recognition below the minimum size for this entity
(* romstyle = "M10K", altera_attribute = "-name ALLOW_ANY_ROM_SIZE_FOR_RECOGNITION ON" *)
module ROM_Sync
 (clk, ADDRESS, DataOut);
input clk;
input [7:0] ADDRESS;
output reg [7:0] DataOut;

always @ (posedge clk)
  begin
    case (ADDRESS)
	8'd1: DataOut = 8'h48;
	8'd2: DataOut = 8'h65;
	8'd3: DataOut = 8'h6c;
	8'd4: DataOut = 8'h6c;
	8'd5: DataOut = 8'h6f;
	8'd6: DataOut = 8'h20;
	8'd7: DataOut = 8'h77;
	8'd8: DataOut = 8'h65;
	8'd9: DataOut = 8'h6c;
	8'd10: DataOut = 8'h63;
	8'd11: DataOut = 8'h6f;
	8'd12: DataOut = 8'h6d;
	8'd13: DataOut = 8'h65;
	8'd14: DataOut = 8'h20;
	8'd15: DataOut = 8'h74;
	8'd16: DataOut = 8'h6f;
	8'd17: DataOut = 8'h20;
	8'd18: DataOut = 8'h49;
	8'd19: DataOut = 8'h54;
	8'd20: DataOut = 8'h45;
	8'd21: DataOut = 8'h53;
	8'd22: DataOut = 8'h4f;
	default: DataOut = 8'h40;
    endcase
  end
endmodule
