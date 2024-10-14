`timescale 1ns/1ps

// lab1 gate-level-only
// don't use primitive XOR directly
// name all your gates
module Toggle_Flip_Flop(clk, q, t, rst_n);
input clk;
input t;
input rst_n;
output q;



endmodule


//gate-level stuff only
module MyXOR(a, b, f);

input a, b;
output f;


endmodule

// DFF with 2 D-latches, tested
module D_Flip_Flop(clk, d, q);
input clk;
input d;
output q;

endmodule

module D_Latch(e, d, q);
input e;
input d;
output q;


endmodule
