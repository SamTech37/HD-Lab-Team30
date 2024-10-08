`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg direction;
output reg [4-1:0] out;

reg next_count; //1 up, 0 down





//seq block
always @(posedge clk) begin
    if(!rst_n) begin //reset
        out <= min;
        direction <= 1'b1;
        next_count <= 1'b1;
    end
    else if(enable && max>min && out<=max && out>=min) begin
    //counter is enabled and in range
        out <= (next_count)? out+1 : out-1;
        direction <= next_count;
    end
    else 
        out <= out; // hold value when disabled, out-of-range 
end

//comb block
always @(*) begin
    if(next_count)
        next_count = (out == max || flip)? 1'b0 : 1'b1;
    else
        next_count = (out == min || flip)? 1'b1 : 1'b0;
end


endmodule
