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


module Crossbar_2x2_4bit_fpga(in1,in2,control,out1,out2);
input [4-1:0] in1, in2;
input control;
output [4-1:0] out1, out2;


Crossbar_2x2_4bit simple_cross(
    .in1(in1),
    .in2(in2),
    .control(control),
    .out1(out1),
    .out2(out2)
);


endmodule
