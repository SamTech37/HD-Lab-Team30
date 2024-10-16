`timescale 1ns/1ps

module Ping_Pong_Counter (clk, rst_n, enable, direction, out);
input clk, rst_n;// clock signal & master reset
input enable;
output reg direction;
output reg [4-1:0] out;

reg [4-1:0] next_count; // 1 = count up, 0 = count down
parameter max_count = 4'b1111;
parameter min_count = 4'b0000;
assign next_count = (out == max_count || (direction == 0 && out != min_count))? (count - 1) : (count + 1);
always @(posedge clk) begin
    if(!rst_n) begin
        
    end
end

endmodule