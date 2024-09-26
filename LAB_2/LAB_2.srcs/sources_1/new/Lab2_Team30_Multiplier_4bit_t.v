`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 12:19:03 AM
// Design Name: 
// Module Name: Lab2_Team30_Multiplier_4bit_t
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


module Multiplier_4bit_T();
//I/O signals
reg [4-1:0] a = 4'b0000, b = 4'b0001;
wire [8-1:0] p;

//test instance
Multiplier_4bit mul(.a(a), .b(b), .p(p));


reg error = 1'b0;
//run through all possible cases
initial begin

repeat (2**8) begin
    
    #1
    error = !(p===a*b);

    #1 
    {a,b} = {a,b}+1'b1;
end

#1 $finish;
end


endmodule
