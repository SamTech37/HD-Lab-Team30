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


module Team30_Crossbar_4x4_4bit_t();
//I/O signals
reg [4-1:0] in1=4'b0000, in2=4'b0001, in3=4'b0010, in4=4'b0011;
reg [5-1:0] control=5'b00000;
wire [4-1:0] out1, out2, out3, out4;

Crossbar_4x4_4bit cross4x4(
    .in1(in1), .in2(in2), 
    .in3(in3), .in4(in4), 
    .out1(out1), .out2(out2),
     .out3(out3), .out4(out4), .control(control));

initial begin
    repeat (2**5) begin
        #1 control = control + 1;
    end
    #1 $finish;
end

endmodule
