`timescale 1ns/1ps

module Crossbar_4x4_4bit(in1, in2, in3, in4, out1, out2, out3, out4, control);
input [4-1:0] in1, in2, in3, in4;
input [5-1:0] control;
output [4-1:0] out1, out2, out3, out4;
wire [3:0] temp1, temp2, temp3, temp4, temp5, temp6;
//temp1 connect 0, 1
//temp2 connect 0, 2
//temp3 connect 2, 1
//temp4 connect 3, 2
//temp5 connect 2, 4
//temp6 connect 3, 4
Crossbar_2x2_4bit C0(in1, in2, control[0], temp1, temp2);
Crossbar_2x2_4bit C3(in3, in4, control[3], temp4, temp6);
Crossbar_2x2_4bit C2(temp2, temp4, control[2], temp3, temp5);
Crossbar_2x2_4bit C1(temp1, temp3, control[1], out1, out2);
Crossbar_2x2_4bit C4(temp5, temp6, control[4], out3, out4);
endmodule
