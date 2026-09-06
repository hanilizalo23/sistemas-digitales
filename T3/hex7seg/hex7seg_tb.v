`timescale 1ns/1ps

module hex7seg_tb;

    reg  w, x, y, z;
    wire a, b, c, d, e, f, g;

    integer i;
    
    // only for waveform
    wire [3:0] hex_value = {w, x, y, z};
    wire [6:0] seg_bus   = {a, b, c, d, e, f, g};

    hex7seg dut (
        .w(w), .x(x), .y(y), .z(z),
        .a(a), .b(b), .c(c),
        .d(d), .e(e), .f(f), .g(g)
    );

    initial begin
        $display("value | w x y z | a b c d e f g");
        for (i = 0; i < 16; i = i + 1) begin
            {w, x, y, z} = i;
            #10;
            $display("  %h   | %b %b %b %b | %b %b %b %b %b %b %b",
                     i, w, x, y, z, a, b, c, d, e, f, g);
        end
        $stop;
    end

endmodule
