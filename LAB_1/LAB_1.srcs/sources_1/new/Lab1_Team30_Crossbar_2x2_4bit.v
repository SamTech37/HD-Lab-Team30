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
