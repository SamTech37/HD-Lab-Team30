`timescale 1ns/1ps

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
