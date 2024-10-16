`timescale 1ns/1ps


//fixed typo
module Toggle_Flip_Flop(clk, q, t, rst_n);
input clk;
input t;
input rst_n;
output q;

wire t1,t2; //come up with better names

MyXOR exor(q,t,t1);
and a1(t2,t1,rst_n);
D_Flip_Flop DFF(clk,t2,q);


endmodule


//gate-level stuff only
module MyXOR(a, b, f);
input a, b;
output f;
wire na,nb;
wire t1,t2;

not n1(na,a);
not n2(nb,b);
and a1(t1,na,b);
and a2(t2,a,nb);
or o1(f,t1,t2);
endmodule

// DFF with 2 D-latches
//tested
module D_Flip_Flop(clk, d, q);
input clk;
input d;
output q;

wire temp;
wire nclk;

not n1(nclk,clk);
D_Latch mas(nclk,d,temp);
D_Latch sla(clk,temp,q);

endmodule

module D_Latch(e, d, q);
input e;
input d;
output q;

wire nd;
wire t1,t2;
wire out, nout;

not n1(nd,d);
nand na1(t1,d,e);
nand na2(t2,nd,e);
nand na3(out,t1,nout);
nand na4(nout,t2,out);

not n2(q,nout);

endmodule
