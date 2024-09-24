`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2024 10:13:41 PM
// Design Name: 
// Module Name: Lab2_Team30_Carry_Look_Ahead_Adder_8bit_t
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


//testbench for 8-bit CLA
module Carry_Look_Ahead_Adder_8bit_T();
// I/O signals
reg [8-1:0] a = 8'b0000_0000, b=8'b0000_0000;
reg cin = 1'b0;
wire [8-1:0] s;
wire cout;

Carry_Look_Ahead_Adder_8bit CLA_8bit(.a(a), .b(b), .c0(cin), .s(s), .c8(cout));

initial begin
    repeat (2**3) begin
        #1 cin=~cin;
        a = (a << 2) + 1;//right shift 2-bits then add 1
        b = (b << 1) + 1;
    end
    #1 $finish;
end
endmodule