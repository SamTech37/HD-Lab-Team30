`timescale 1ns/1ps 

//this is a bonus question
module Booth_Multiplier_4bit_T();
reg clk = 1'b0;
reg rst_n = 1'b1; 
reg start;
reg signed [3:0] a, b;
wire signed [7:0] p;

// Instantiate the Unit Under Test (UUT)   
Booth_Multiplier_4bit BM_4bit (
    .clk(clk), 
    .rst_n(rst_n), 
    .start(start), 
    .a(a), 
    .b(b), 
    .p(p)
);


parameter cyc = 10;
always @(cyc/2) clk = ~clk;
    

initial begin


    #(cyc) $finish;
end


endmodule
