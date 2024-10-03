`timescale 1ns / 1ps

module Ping_Pong_Counter_T();
// I/O signals
reg clk, rst_n;
reg enable;
wire direction;
wire [4-1:0] out;

//test instance
Ping_Pong_Counter (.clk(clk), .rst_n(rst_n), .enable(enable), .direction(direction), .out(out));


//run through all possible cases
reg error = 1'b0;
initial begin

repeat (2**8) begin
    
    //raise error if the count is not correct
    
end

#1 $finish;
end


endmodule
