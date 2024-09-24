`timescale 1ns/1ps

//8-bit RCA
module Ripple_Carry_Adder(a, b, cin, cout, sum);
input [8-1:0] a, b;
input cin;
output cout;
output [8-1:0] sum;

wire [8-1:0] c;

Full_Adder fa0(a[0],b[0],cin,c[1],sum[0]);
Full_Adder fa1(a[1],b[1],c[1],c[2],sum[1]);
Full_Adder fa2(a[2],b[2],c[2],c[3],sum[2]);
Full_Adder fa3(a[3],b[3],c[3],c[4],sum[3]);

Full_Adder fa4(a[4],b[4],c[4],c[5],sum[4]);
Full_Adder fa5(a[5],b[5],c[5],c[6],sum[5]);
Full_Adder fa6(a[6],b[6],c[6],c[7],sum[6]);
Full_Adder fa7(a[7],b[7],c[7],cout,sum[7]);


endmodule



//remember to add the NAND implementations into this file
//before submitting the code

module Half_Adder(a, b, cout, sum);
input a, b;
output cout, sum;

MyAnd a1(cout,a,b);
MyXor ex(sum,a,b);
endmodule

module Full_Adder (a, b, cin, cout, sum);
input a, b, cin;
output cout, sum;

wire s0;

Majority maj(a,b,cin,cout);
Half_Adder ha1(.a(a), .b(b), .sum(s0));
Half_Adder ha2(.a(s0), .b(cin), .sum(sum));
endmodule

module Majority(a, b, c, out);
input a, b, c;
output out;
wire t0,t1,t2,t3;

MyAnd a1(t0,a,b);
MyAnd a2(t1,b,c);
MyAnd a3(t2,c,a);
MyXor ex1(t3,t0,t1);
MyXor ex2(out,t2,t3);
endmodule