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
always #(cyc/2) clk = ~clk;
    

initial begin
    @(negedge clk)
    rst_n = 1'b0;
    a = 4'd3;
    b = 4'd5;
    start = 1'b0;
    @(negedge clk)
    rst_n = 1'b1;
    a = 4'd10;
    b = 4'd3;
    
    
    #(10*cyc)
    a = 4'b0011;
    b = 4'b1100;
    start = 1'b1;
    
    #(25*cyc)
    // a = 16'd169;
    // b= 16'd39;
    
    // #(20*cyc)
    // a = 16'd0;
    // b = 16'd6;
    
    // #(3*cyc)
    // start = 1'b0;

    #(cyc) $finish;
end


endmodule

