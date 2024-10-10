`timescale 1ns/1ps

module Ping_Pong_Counter (clk, rst_n, enable, direction, out);
input clk, rst_n;// clock signal & master reset
input enable;
output reg direction;
output reg [4-1:0] out;

reg next_count; // 1 = count up, 0 = count down
parameter max_count = 4'b1111;
parameter min_count = 4'b0000;

//seq block
// "<=" only
always @(posedge clk) begin
    if(!rst_n) begin
        out <= 4'b0000;
        direction <= 1'b1;
    end 
    else if(enable) begin
        //where the ping-pong happens
        out <= (next_count)? out+1 : out-1;
        direction <= next_count;
    end
    else begin
        out <= out; // do nothing when disabled
        direction <= direction;
    end
end

//comb block
always @(*) begin
    if(out == max_count)
        next_count = 1'b0;
    else if(out == min_count)
        next_count = 1'b1;
    else 
        next_count = direction;
end

endmodule
