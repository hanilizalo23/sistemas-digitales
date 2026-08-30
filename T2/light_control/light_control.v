module light_control (
   input  wire a,
   input  wire b,
   input  wire c,
   output wire s0
);

assign s0 = (~a & ~b &  c)  // minterm 1
          | (~a &  b & ~c)  // minterm 2
          | ( a & ~b & ~c)  // minterm 4
          | ( a &  b &  c); // minterm 7

endmodule
