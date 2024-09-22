`timescale 1ns/1ps

module Crossbar_2x2_4bit(in1, in2, control, out1, out2);
input [4-1:0] in1, in2;
input control;
output [4-1:0] out1, out2;
wire controlbar;
wire [3:0] tout1, tout2, tout3, tout4;
//tout1, tout2 for Dmux1
//tout3, tout4 for Dmux2
not N1(controlbar, control);
Dmux_1x2_4bit Dmux1(in1, tout1, tout2, control);
Dmux_1x2_4bit Dmux2(in2, tout3, tout4, controlbar);
Mux_2x1_4bit Mux1(tout1, tout3, control, out1);
Mux_2x1_4bit Mux2(tout2, tout4, controlbar, out2);
endmodule

/*
submodules used
*/



module Dmux_1x2_4bit(in, out1, out2, sel);
input [3:0] in;
input sel;
wire selbar;
output [3:0] out1, out2;
not NOT(selbar, sel);
and AND1_1(out1[0], in[0], selbar);
and AND1_2(out1[1], in[1], selbar);
and AND1_3(out1[2], in[2], selbar);
and AND1_4(out1[3], in[3], selbar);
and AND2_1(out2[0], in[0], sel);
and AND2_2(out2[1], in[1], sel);
and AND2_3(out2[2], in[2], sel);
and AND2_4(out2[3], in[3], sel);
endmodule


module Dmux_1x4_4bit(in, a, b, c, d, sel);
input [4-1:0] in;
input [2-1:0] sel;
wire [3:0] ab;
wire [3:0] cd;
output [4-1:0] a, b, c, d;
Dmux_1x2_4bit Dmux1(in, ab, cd, sel[1]);
//Dmux1 use sel[1] to select ab or cd
Dmux_1x2_4bit Dmux2(ab, a, b, sel[0]);
//Dmux2 use sel[0] to select a or b
Dmux_1x2_4bit Dmux3(cd, c, d, sel[0]);
//Dmux3 use sel[0] to select c or d
endmodule


module Mux_2x1_4bit(in1, in2, sel, f);
input [4-1:0] in1, in2;
input sel;
output [4-1:0] f;
wire [3:0] out1, out2;
wire selbar;
not N(selbar, sel);
and AND1_1(out1[0], in1[0], selbar);
and AND1_2(out1[1], in1[1], selbar);
and AND1_3(out1[2], in1[2], selbar);
and AND1_4(out1[3], in1[3], selbar);
and AND2_1(out2[0], in2[0], sel);
and AND2_2(out2[1], in2[1], sel);
and AND2_3(out2[2], in2[2], sel);
and AND2_4(out2[3], in2[3], sel);
or OR(f[0], out1[0], out2[0]);
or OR1(f[1], out1[1], out2[1]);
or OR2(f[2], out1[2], out2[2]);
or OR3(f[3], out1[3], out2[3]);

endmodule


module Mux_4x1_4bit(a, b, c, d, sel, f);
input [4-1:0] a, b, c, d;
input [2-1:0] sel;
output [4-1:0] f;
wire [3:0] out1, out2;
Mux_2x1_4bit M1(a, b, sel[0], out1);
Mux_2x1_4bit M2(c, d, sel[0], out2);
Mux_2x1_4bit M3(out1, out2, sel[1], f);

endmodule