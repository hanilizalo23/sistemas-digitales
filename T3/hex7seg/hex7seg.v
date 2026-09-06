module hex7seg (
	input  wire w,
	input  wire x,
	input  wire y,
	input  wire z,
	
	output wire a,
	output wire b,
	output wire c,
	output wire d,
	output wire e,
	output wire f,
	output wire g
);

assign a = (~w & ~x & ~y &  z)
         | (~w &  x & ~y & ~z)
         | ( w &  x & ~y &  z)
         | ( w & ~x &  y &  z);

assign b = ( x &  y & ~z)
         | ( w &  x & ~z)
         | ( w &  y &  z)
         | (~w &  x & ~y &  z);

assign c = ( w &  x & ~z)
         | ( w &  x &  y)
         | (~w & ~x &  y & ~z);

assign d = ( x &  y &  z)
         | (~w & ~x & ~y &  z)
         | (~w &  x & ~y & ~z)
         | ( w & ~x &  y & ~z);

assign e = (~w &  z)
         | (~w &  x & ~y)
         | (~x & ~y &  z);

assign f = (~w & ~x &  z)
         | (~w & ~x &  y)
         | (~w &  y &  z)
         | ( w &  x & ~y &  z);

assign g = (~w & ~x & ~y)
         | (~w &  x &  y &  z)
         | ( w &  x & ~y & ~z);

endmodule
