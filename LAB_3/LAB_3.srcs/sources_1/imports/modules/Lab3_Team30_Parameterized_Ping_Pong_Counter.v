`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg direction;
output reg [4-1:0] out;

reg next_direction; //1 up, 0 down

//seq block
always @(posedge clk) begin
    if(!rst_n) begin //reset
        out <= min;
        direction <= 1'b1;
    end
    else if(enable && max>min && out<=max && out>=min) begin
    //counter is enabled and in range
        out <= (next_direction)? out+1 : out-1;
        direction <= next_direction;
    end
    else begin // hold value when disabled or out-of-range 
        out <= out; 
        direction <= direction;
    end
end

//comb block
always @(*) begin
    if(out == max)
        next_direction = 1'b0;
    else if(out == min)
        next_direvtion = 1'b1;
    else if (flip)
        next_direction = !direction;
    else
        next_direction = direction;
        
end


endmodule
