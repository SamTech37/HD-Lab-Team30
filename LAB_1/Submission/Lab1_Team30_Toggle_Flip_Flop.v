`timescale 1ns/1ps

module Toggle_Flip_Flop(clk, q, t, rst_n);
input clk;
input t;
input rst_n;
output q;

wire q0,d,temp;

MyXOR exor(.f(temp),.a(q0),.b(t));
and(d,temp,rst_n);
D_Flip_Flop dff(.clk(clk), .d(d), .q(q0) );

and(q, 1'b1, q0); //output q0 as q


endmodule


/*
submodules used
*/

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

endmodule

// DFF with 2 D-latches, tested
module D_Flip_Flop(clk, d, q);
input clk;
input d;
output q;

wire nclk;
wire temp;

not(nclk,clk);
D_Latch mas(nclk,d,temp);
D_Latch sla(clk,temp,q);

endmodule

module D_Latch(e, d, q);
input e;
input d;
output q;

wire nd, q0, nq0;
wire t1, t2;

not(nd,d);
nand(t1,d,e);
nand(t2,nd,e);
nand(q0, t1, nq0);
nand(nq0, t2, q0);
not(q, nq0);

endmodule
