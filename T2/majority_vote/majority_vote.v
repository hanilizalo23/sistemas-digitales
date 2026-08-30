module majority_vote (
   input  wire a,
   input  wire b,
   input  wire c,
   output wire s1
);

assign s1 = (~a &  b &  c)  // minterm 3
          | ( a & ~b &  c)  // minterm 5
          | ( a &  b & ~c)  // minterm 6
          | ( a &  b &  c); // minterm 7

endmodule
