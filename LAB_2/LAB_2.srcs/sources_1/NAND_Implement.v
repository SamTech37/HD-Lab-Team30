`timescale 1ns/1ps

module NAND_Implement (a, b, sel, out);
input a, b;
input [3-1:0] sel;
output out;

wire t0,t1,t2,t3,t4,t5,t6;
wire s1,s2;
nand(t0,a,b);
MyAnd a1(t1,a,b);
MyOr o1(t2,a,b);
MyNor no1(t3,a,b);

MyXor ex(t4,a,b);
MyXnor exn(t5,a,b);
MyNot neg(t6,a);

MUX_4x1 m1(t0,t1,t2,t3, sel[1:0],s1);
MUX_4x1 m2(t4,t5,t6,t6, sel[1:0],s2);
MUX_2x1 m3(s1,s2,sel[2], out);




endmodule


module MUX_2x1(a,b,sel,out);
input a,b, sel;
output out;

wire t1,t2;
wire nsel;
MyNot neg(nsel,sel);

MyAnd a1(t1, a,nsel);
MyAnd a2(t2, b,sel);
MyOr o1(out, t1,t2);
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


//
module MyNot(f,a);
input a;
output f;

nand(f,a,a);
endmodule

//
module MyAnd(f,a,b);
input a,b;
output f;
wire temp;

nand(temp,a,b);
MyNot n1(f,temp);
endmodule

//
module MyOr(f,a,b);
input a,b;
output f;
wire t1,t2;

MyNot n1(t1,a);
MyNot n2(t2,b);

nand(f,t1,t2);
endmodule


module MyNor(f,a,b);
input a,b;
output f;
wire t;

MyOr o1(t,a,b);
MyNot neg(f,t);
endmodule


module MyXor(f,a,b);
input a,b;
output f;
wire na,nb;
wire t1,t2;

MyNot neg1(na,a);
MyNot neg2(nb,b);
MyAnd a1(t1,na,b);
MyAnd a2(t2,a,nb);
MyOr o1(f,t1,t2);
endmodule


module MyXnor(f,a,b);
input a,b;
output f;
wire t;
MyXor exor(t,a,b);
MyNot neg(f,t);
endmodule
