`timescale 1ns/1ps

module Ping_Pong_Counter (clk, rst_n, enable, direction, out);
input clk, rst_n;// clock signal & master reset
input enable;
output reg direction;// 1 = count up, 0 = count down
output reg [4-1:0] out;

parameter max_count = 4'b1111;
parameter min_count = 4'b0000;

//seq block
always @(posedge clk) begin
    if(!rst_n) begin
        out <= 4'b0000;
        direction = 1'b1;
    end 
    else if(enable) begin
        if(direction) begin
        out <= (out == max_count)? out-1 : out+1;
        direction <= (out == max_count)? !direction : direction;
        end
        else begin
        out <= (out == min_count)? out+1 : out-1;
        direction <= (out == min_count)? !direction : direction;
        end
    end
    else 
        out <= out; // do nothing
        
end

endmodule
