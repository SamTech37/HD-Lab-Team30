`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2024 04:59:46 PM
// Design Name: 
// Module Name: Lab1_Team30_Crossbar_2x2_4bit_fpga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Crossbar_2x2_4bit_fpga(in1,in2,control,out1_a,out1_b,out2_a,out2_b);
input [4-1:0] in1, in2;
input control;
output [4-1:0] out1_a, out1_b;
output [4-1:0] out2_a, out2_b;

wire [4-1:0] out1,out2;

Crossbar_2x2_4bit simple_cross(
    .in1(in1),
    .in2(in2),
    .control(control),
    .out1(out1),
    .out2(out2)
);

fanout_1x2_4bit f1(out1, out1_a,out1_b);
fanout_1x2_4bit f2(out2, out2_a,out2_b);


endmodule

module fanout_1x2_4bit(in,out1,out2);
input [4-1:0] in;
output [4-1:0] out1,out2;

wire [4-1:0] t;
not(t[0],in[0]);
not(t[1],in[1]);
not(t[2],in[2]);
not(t[3],in[3]);

not(out1[0],t[0]);
not(out1[1],t[1]);
not(out1[2],t[2]);
not(out1[3],t[3]);

not(out2[0],t[0]);
not(out2[1],t[1]);
not(out2[2],t[2]);
not(out2[3],t[3]);

endmodule
