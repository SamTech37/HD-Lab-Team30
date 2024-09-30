`timescale 1ns / 1ps

module Multiplier_4bit_T();
//I/O signals
reg [4-1:0] a = 4'b0000, b = 4'b0001;
wire [8-1:0] p;

//test instance
Multiplier_4bit mul(.a(a), .b(b), .p(p));


//run through all possible cases
reg error = 1'b0;
initial begin

repeat (2**8) begin
    
    //raise error if the product is not correct
    #1
    error = !(p===a*b);

    #1 
    {a,b} = {a,b}+1'b1;
end

#1 $finish;
end


endmodule
