`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg direction;
output reg [4-1:0] out;


//[TODO]
//handle enable
//handle max & min & out-of-range
//handle flip 

//seq block
always @(posedge clk) begin
    if(!rst_n) begin //reset
        out <= min;
        direction = 1'b1;
    end 
    else if(enable && max>min) begin
        if(direction) begin
        out <= (out == max)? out-1 : out+1;
        direction <= (out == max || flip)? !direction : direction;
        end
        else begin
        out <= (out == min)? out+1 : out-1;
        direction <= (out == min || flip)? !direction : direction;
        end
    end
    else 
        out <= out; // do nothing when disabled
        
end


//comb block

endmodule
