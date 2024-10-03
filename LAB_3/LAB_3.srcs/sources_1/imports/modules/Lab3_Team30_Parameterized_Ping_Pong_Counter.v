`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg direction;
output reg [4-1:0] out;

//seq block
//beware of the complex conditional branches
always @(posedge clk) begin
    if(!rst_n) begin
        out <= 4'b0000;
        direction = 1'b1;
    end 
    else if(enable) begin
        
    end
    else 
        out <= out; // do nothing
        
end
endmodule
