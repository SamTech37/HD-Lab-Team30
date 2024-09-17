`timescale 1ns/1ps
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
