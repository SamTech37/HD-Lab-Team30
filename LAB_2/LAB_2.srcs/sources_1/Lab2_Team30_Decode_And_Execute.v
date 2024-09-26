`timescale 1ns/1ps
module Universal_Gate(out, a, b);
input a, b;
wire bbar;
output out;
not N1(bbar, b);
and A1(out, a, bbar);
endmodule

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
output out;
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

/*
module Half_Substracter(a, b, d, bi1);
//a-b, bi1 means borrow from the previous bit, d means the difference between a and b
input a, b;
output d, bi1;
wire abar;
NOT N1(abar, a);
XOR X1(d, a, b);
AND A1(bi1, abar, b);
endmodule

module Full_Substracter(a, b, bi, d, bi1);
//a-b, bi means lend to the next bit, bi1 means borrow from the previous bit, d means the difference between a and b
input a, b, bi;
output d, bi1;
wire tempbi1, tempd, tbi1;
Half_Substracter HS1(a, b, tempd, tempbi1);
Half_Substracter HS2(tempd, bi, d, tbi1);
OR O1(bi1, tempbi1, tbi1);
endmodule

//4-bit RBS
module Ripple_Borrow_Subtracter(rs, rt, rd);
input [3:0] rs, rt;
output [3:0] rd;
wire [3:0] b;

Full_Subtracter fs0(rs[0], rt[0], 0, rd[0], b[0]);
Full_Subtracter fs1(rs[1], rt[1], b[0], rd[1], b[1]);
Full_Subtracter fs2(rs[2], rt[2], b[1], rd[2], b[2]);
Full_Subtracter fs3(rs[3], rt[3], b[2], rd[3], b[3]);
endmodule*/

module Ripple_Borrow_Subtracter(rs, rt, rd);
input [3:0] rs;
input [3:0] rt;
output [3:0] rd;
wire [3:0] temprt, trt;
//2's complement
NOT N1(temprt[0], rt[0]);
NOT N2(temprt[1], rt[1]);
NOT N3(temprt[2], rt[2]);
NOT N4(temprt[3], rt[3]);
RRipple_Carry_Adder RCA1(temprt, 4'b0001, trt);
RRipple_Carry_Adder RCA2(rs, trt, rd);
endmodule

module Half_Adder(a, b, cout, sum);
input a, b;
output cout, sum;
XOR X1(sum, a, b);
AND A1(cout, a, b);
endmodule

module Full_Adder (a, b, cin, cout, sum);
input a, b, cin;
output cout, sum;
wire tempc, temps, tc;
Half_Adder H1(a, b, tempc, temps);
Half_Adder H2(cin, temps, tc, sum);
XOR X1(cout, tempc, tc);
endmodule

module RRipple_Carry_Adder(a, b, sum);
input [3:0] a, b;
output [3:0] sum;
wire [3:0] c;
Full_Adder fa0(a[0],b[0],1'b0,c[0],sum[0]);
Full_Adder fa1(a[1],b[1],c[0],c[1],sum[1]);
Full_Adder fa2(a[2],b[2],c[1],c[2],sum[2]);
Full_Adder fa3(a[3],b[3],c[2],c[3],sum[3]);
endmodule

module Bit_Wise_OR(rs, rt, rd);
input [3:0] rs;
input [3:0] rt;
output [3:0] rd;
OR O1(rd[0], rs[0], rt[0]);
OR O2(rd[1], rs[1], rt[1]);
OR O3(rd[2], rs[2], rt[2]);
OR O4(rd[3], rs[3], rt[3]);
endmodule

module Bit_Wise_AND(rs, rt, rd);
input [3:0] rs;
input [3:0] rt;
output [3:0] rd;
AND A1(rd[0], rs[0], rt[0]);
AND A2(rd[1], rs[1], rt[1]);
AND A3(rd[2], rs[2], rt[2]);
AND A4(rd[3], rs[3], rt[3]);
endmodule

module Right_Shift(rt, rd);
input [3:0] rt;
output [3:0] rd;
AND A1(rd[0], rt[1], 1);
AND A2(rd[1], rt[2], 1);
AND A3(rd[2], rt[3], 1);
AND A4(rd[3], rt[3], 1);
endmodule

module Left_Shift(rs, rd);
input [3:0] rs;
output [3:0] rd;
AND A1(rd[0], rs[3], 1);
AND A2(rd[1], rs[0], 1);
AND A3(rd[2], rs[1], 1);
AND A4(rd[3], rs[2], 1);
endmodule

module COMPARE_LT(rs, rt, rd);
//(rs < rt) = (rs[3])'(rt[3]) + (x[3])(rs[2])'(rt[2]) + (x[3])(x[2])(rs[1])'(rt[1]) + (x[3])(x[2])(x[1])(rs[0])'(rt[0])
input [3:0] rs, rt;
output [3:0] rd;
wire [3:0] x;
wire rs0b, rs1b, rs2b, rs3b, ans3, ans2, ans1, ans0;
NOT N1(rs0b, rs[0]);
NOT N2(rs1b, rs[1]);
NOT N3(rs2b, rs[2]);
NOT N4(rs3b, rs[3]);
X_Produce XP1(x[3], rs[3], rt[3]);
X_Produce XP2(x[2], rs[2], rt[2]);
X_Produce XP3(x[1], rs[1], rt[1]);
wire t0, t1, t2, t3, t4, t5, o1, o2, f1;
AND A1(t3, rs3b, rt[3]);
AND A2(ans2, rs2b, rt[2]);
AND A3(ans1, rs1b, rt[1]);
AND A4(ans0, rs0b, rt[0]);
AND A5(t2, ans2, x[3]);
AND A6(t4, x[3], x[2]);
AND A7(t1, ans1, t4);
AND A8(t5, t4, x[1]);
AND A9(t0, ans0, t5);
OR O1(o1, t0, t1);
OR O2(o2, t2, t3);
OR O3(f1, o1, o2);
AND A10(rd[3], 1, 1);
AND A11(rd[2], 1, 0);
AND A12(rd[1], 1, 1);
AND A13(rd[0], 1, f1);
endmodule

module COMPARE_EQ(rs, rt, rd);
input [3:0] rs, rt;
output [3:0] rd;
wire [3:0] x;
wire t1, t2;
AND A1(rd[3], 1, 1);
AND A2(rd[2], 1, 1);
AND A3(rd[1], 1, 1);
X_Produce XP0(x[0], rs[0], rt[0]);
X_Produce XP1(x[1], rs[1], rt[1]);
X_Produce XP2(x[2], rs[2], rt[2]);
X_Produce XP3(x[3], rs[3], rt[3]);
AND A4(t1, x[0], x[1]);
AND A5(t2, x[2], x[3]);
AND A6(rd[0], t1, t2);
endmodule

module X_Produce(x, a, b);
input a, b;
output x;
wire abar, bbar, t1, t2;
NOT N1(abar, a);
NOT N2(bbar, b);
AND A1(t1, a, b);
AND A2(t2, abar, bbar);
OR O1(x, t1, t2);
endmodule

module MUX_2x1(a,b,sel,out);
input a,b, sel;
output out;

wire t1,t2;
wire nsel;
NOT N1(nsel,sel);

AND A1(t1, a, nsel);
AND A2(t2, b, sel);
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
input [3:0] rs, rt;
input [2:0] sel;
output [3:0] rd;
wire [3:0] t0, t1, t2, t3, t4, t5, t6, t7, s1, s2;
Ripple_Borrow_Subtracter RBS1(rs, rt, t0);
RRipple_Carry_Adder RCA1(rs, rt, t1);
Bit_Wise_OR BWR1(rs, rt, t2);
Bit_Wise_AND BWA1(rs, rt, t3);
Right_Shift RS1(rt, t4);
Left_Shift LS1(rs, t5);
COMPARE_LT CL1(rs, rt, t6);
COMPARE_EQ CE1(rs, rt, t7);
MUX_4x1 m1(t0[0],t1[0],t2[0],t3[0], sel[1:0], s1[0]);
MUX_4x1 m2(t0[1],t1[1],t2[1],t3[1], sel[1:0], s1[1]);
MUX_4x1 m3(t0[2],t1[2],t2[2],t3[2], sel[1:0], s1[2]);
MUX_4x1 m4(t0[3],t1[3],t2[3],t3[3], sel[1:0], s1[3]);
MUX_4x1 m5(t4[0],t5[0],t6[0],t7[0], sel[1:0], s2[0]);
MUX_4x1 m6(t4[1],t5[1],t6[1],t7[1], sel[1:0], s2[1]);
MUX_4x1 m7(t4[2],t5[2],t6[2],t7[2], sel[1:0], s2[2]);
MUX_4x1 m8(t4[3],t5[3],t6[3],t7[3], sel[1:0], s2[3]);
MUX_2x1 m9(s1[0],s2[0],sel[2], rd[0]);
MUX_2x1 m10(s1[1],s2[1],sel[2], rd[1]);
MUX_2x1 m11(s1[2],s2[2],sel[2], rd[2]);
MUX_2x1 m12(s1[3],s2[3],sel[2], rd[3]);
endmodule
