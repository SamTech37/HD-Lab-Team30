`timescale 1ns/1ps

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

wire na,nb;
wire t1,t2;

not(na,a);
not(nb,b);
and(t1, a, nb);
and(t2, na, b);
or(f, t1, t2);

endmodule;
