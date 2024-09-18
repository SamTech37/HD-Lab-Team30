`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2024 04:07:53 PM
// Design Name: 
// Module Name: Lab1_Team30_Crossbar_2x2_4bit_t
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


module Crossbar_2x2_4bit_T();
// I/O signals
reg [4-1:0] in1 = 4'b0000, in2=4'b0001;
reg control = 1'b0;
wire [4-1:0] out1, out2;

Crossbar_2x2_4bit cross2x2(
    .in1(in1),
    .in2(in2),
    .control(control),
    .out1(out1),
    .out2(out2)
);

initial begin
    repeat (2**1) begin
        #1 control = ~control;
        in1 = in1 + 2;
        in2 = in2 + 2;
    end
    #1 $finish;
end

endmodule
