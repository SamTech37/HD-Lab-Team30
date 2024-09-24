`timescale 1ns/1ps

module Multiplier_4bit(a, b, p);
input [4-1:0] a, b;
output [8-1:0] p;

wire [4-1:0] tp0, tp1, tp2, tp3;

//partial products
MyAnd A1(tp0[0],a[0],b[0]);
MyAnd A2(tp0[1],a[1],b[0]);
MyAnd A3(tp0[2],a[2],b[0]);
MyAnd A4(tp0[3],a[3],b[0]);

MyAnd A5(tp1[0],a[0],b[1]);
MyAnd A6(tp1[1],a[1],b[1]);
MyAnd A7(tp1[2],a[2],b[1]);
MyAnd A8(tp1[3],a[3],b[1]);

MyAnd A9(tp2[0],a[0],b[2]);
MyAnd A10(tp2[1],a[1],b[2]);
MyAnd A11(tp2[2],a[2],b[2]);
MyAnd A12(tp2[3],a[3],b[2]);

MyAnd A13(tp3[0],a[0],b[3]);
MyAnd A14(tp3[1],a[1],b[3]);
MyAnd A15(tp3[2],a[2],b[3]);
MyAnd A16(tp3[3],a[3],b[3]);

//sum them up
wire [10:0] co;
MyAnd A17(p[0],tp0[0]);

Full_Adder FA1(tp0[1],tp1[0],0 , co[0],p[1]);

Full_Adder FA2();



endmodule
