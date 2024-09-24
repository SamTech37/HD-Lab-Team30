`timescale 1ns/1ps

module NOT(out, a);
input a;
output out;
nand NAND1(out, a ,a);
endmodule 

module AND(out, a, b);
input a, b;
output out;
wire temp;
nand NAND1(temp, a, b);
NOT N1(out, temp);
endmodule

module OR(out, a, b);
input a, b;
output out;
wire abar, bbar;
NOT N1(abar, a);
NOT N2(bbar, b);
nand NAND1(out, abar, bbar);
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
wire abar, bbar, temp1, temp2;
NOT N1(abar, a);
NOT N2(bbar, b);
AND A1(temp1, a, bbar);
AND A2(temp2, b, abar);
OR O1(out, temp1, temp2);
endmodule

module XNOR(out, a, b);
input a, b;
output out;
wire abar, bbar, temp1, temp2;
NOT N1(abar, a);
NOT N2(bbar, b);
AND A1(temp1, a, b);
AND A2(temp2, bbar, abar);
OR O1(out, temp1, temp2);
endmodule


module Half_Adder(a, b, cout, sum);
input a, b;
output cout, sum;
XOR XO1(sum, a, b);
AND A1(cout, a, b);
endmodule

module Full_Adder (a, b, cin, sum);
input a, b, cin;
output sum;
wire tempc, temps, tc;
Half_Adder H1(a, b, tempc, temps);
Half_Adder H2(cin, temps, tc, sum);
endmodule

module PG_Produce(a, b, p, g);
input [3:0] a, b;
output [3:0] p, g;
AND A1(g[0], a[0], b[0]);
OR O1(p[0], a[0], b[0]);
AND A2(g[1], a[1], b[1]);
OR O2(p[1], a[1], b[1]);
AND A3(g[2], a[2], b[2]);
OR O3(p[2], a[2], b[2]);
AND A4(g[3], a[3], b[3]);
OR O4(p[3], a[3], b[3]);
endmodule

//4bit CLA
module Carry_Look_Ahead_Gen_4bit(c, a, b, g, p, s);
input c;
input [3:0] a, b;
output [3:0] g, p, s;
wire [3:0] g, p;
wire [4:1] cout;
PG_Produce PP1(a, b, p, g);
wire t0, t1, t2, t3;
//Produce C1
AND A1(t0, p[0], c);
OR O1(c[1], g[0], t1);
//Produce C2
AND A2(t1, p[1], c[1]);
OR O2(c[2], g[1], t1);
//Produce C3
AND A2(t2, p[2], c[2]);
OR O2(c[3], g[2], t2);
//Produce [3:0]sum
Full_Adder FA1(a[0], b[0], c, s[0]);
Full_Adder FA2(a[1], b[1], c[1], s[1]);
Full_Adder FA3(a[2], b[2], c[2], s[2]);
Full_Adder FA4(a[3], b[3], c[3], s[3]);
endmodule

module Carry_Look_Ahead_Gen_2bit(cin, g, p, cout);
input cin;
input [3:0] g, p;
output cout;
wire pg, gg, t1, t2, t3, t4, t5, t6, t7, o1, o2;
//pg
AND A1(t1, p[0], p[1]);//p0p1
AND A2(t2, p[2], p[3]);//p2p3
AND A3(pg, t1, t2);
//gg
AND A4(t3, g[2], p[3]);//g2p3
AND A6(t4, t2, g[1]);//g1p3p2
AND A7(t5, g[0], p[1]);//g0p1
AND A8(t6, t2, t5);//g0p3p2p1
OR O1(o1, g[3], t3);
OR O2(o2, t4, t6);
OR O3(gg, o1, o2);
//cg
AND A1(t7, pg, cin);
OR O4(cout, t7, gg);
endmodule

//8bit CLA
module Carry_Look_Ahead_Adder_8bit(a, b, c0, s, c8);
input [8-1:0] a, b;
input c0;
output [8-1:0] s;
output c8;
wire [3:0] g1, g2, p1, p2;
wire c4;
Carry_Look_Ahead_Gen_4bit CLA4_1(c0, a[3:0], b[3:0], g1, p1, s[3:0]);
Carry_Look_Ahead_Gen_2bit CLA2_1(c0, g1, p1, c4);
Carry_Look_Ahead_Gen_4bit CLA4_2(c4, a[7:4], b[7:4], g2, p2, s[7:4]);
Carry_Look_Ahead_Gen_2bit CLA2_2(c4, g2, p2, c8);
endmodule
