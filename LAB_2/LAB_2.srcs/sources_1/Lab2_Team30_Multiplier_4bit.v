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
wire [4-1:0] sum1, sum2, sum3;
wire [4-1:0] aug1, aug2, aug3;
wire co1,co2,co3;
Concat cat1(tp0[1],tp0[2],tp0[3],0,aug1);
RCA_4bit add1(tp1,aug1,co1,sum1);

Concat cat2(sum1[1],sum1[2],sum1[3],co1,aug2);
RCA_4bit add2(tp2,aug2,co2,sum2);

Concat cat3(sum2[1],sum2[2],sum2[3],co2,aug3);
RCA_4bit add3(tp3,aug3,co3,sum3);

MyAnd buf0(p[0],tp0[0],1);
MyAnd buf1(p[1],sum1[0],1);
MyAnd buf2(p[2],sum2[0],1);
MyAnd buf3(p[3],sum3[0],1);
MyAnd buf4(p[4],sum3[1],1);
MyAnd buf5(p[5],sum3[2],1);
MyAnd buf6(p[6],sum3[3],1);
MyAnd buf7(p[7],co3,1);


endmodule


module Concat(in0,in1,in2,in3,out);
input in0,in1,in2,in3;
output [4-1:0] out;

MyAnd a0(out[0],in0,1);
MyAnd a1(out[1],in1,1);
MyAnd a2(out[2],in2,1);
MyAnd a3(out[3],in3,1);

endmodule


//without cin
module RCA_4bit(a,b,cout,sum);
input [4-1:0] a,b;
output [4-1:0] sum;
output cout;

wire [4-1:0] c;

Full_Adder fa0(a[0],b[0], 0,c[1],sum[0]);
Full_Adder fa1(a[1],b[1],c[1],c[2],sum[1]);
Full_Adder fa2(a[2],b[2],c[2],c[3],sum[2]);
Full_Adder fa3(a[3],b[3],c[3],cout,sum[3]);

endmodule