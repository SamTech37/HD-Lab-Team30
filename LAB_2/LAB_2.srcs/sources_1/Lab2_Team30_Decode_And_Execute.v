`timescale 1ns/1ps
module NOT(out, in);
input in;
output out;
//a=1, b=~b
Universal_Gate U1(out, 1, in);
endmodule

module AND(out, a, b);
input a, b;
output out;
wire bbar;
//a&b = a (UNIVERSAL) ~b
NOT N1(bbar, b);
Universal_Gate U1(out, a, bbar);
endmodule

module NAND(out, a, b);
input a, b;
wire temp;
AND A1(temp, a, b);
NOT N1(out, temp);
endmodule

module OR(out, a, b);
input a, b;
output out;
wire bbar, abar;
NOT N1(bbar, b);
NOT N2(abar, a);
NAND NA1(out, abar, bbar);
endmodule

module NOR(out, a, b);
input a, b;
output out;
wire temp;
OR O1(temp, a, b);
NOT N1(out, temp);
endmodule

module XOR(out, a, b);
input a, b;
output out;
wire t1, t2, abar, bbar;
NOT N1(abar, a);
NOT N2(bbar, b);
AND A1(t1, abar, b);
AND A2(t2, bbar, a);
OR O1(out, t1, t2);
endmodule

module XNOR(out, a, b);
input a, b;
output out;
wire t1, t2, abar, bbar;
NOT N1(abar, a);
NOT N2(bbar, b);
AND A1(t1, abar, bbar);
AND A2(t2, a, b);
OR O1(out, t1, t2);
endmodule

module Half_Substracter(a, b, bi, bi1);
//a-b, bi means lend to the next bit, bi1 means borrow from the previous bit
input a, b;
output bi, bi1;


endmodule

module MUX_2x1(a,b,sel,out);
input a,b, sel;
output out;

wire t1,t2;
wire nsel;
Not N1(nsel,sel);

AND A1(t1, a,nsel);
And A2(t2, b,sel);
OR O1(out, t1,t2);
endmodule

module MUX_4x1(a,b,c,d,sel,out);
input a,b,c,d;
input [2-1:0] sel;
output out;
wire t1,t2;

MUX_2x1 m1(a,b,sel[0],t1);
MUX_2x1 m2(c,d,sel[0],t2);
MUX_2x1 m3(t1,t2,sel[1],out);
endmodule

module Decode_And_Execute(rs, rt, sel, rd);
input [4-1:0] rs, rt;
input [3-1:0] sel;
output [4-1:0] rd;

endmodule
