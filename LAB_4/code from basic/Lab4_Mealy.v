`timescale 1ns/1ps

module Mealy (clk, rst_n, in, out, state);
input clk, rst_n;
input in;
output reg out;
output reg [3-1:0] state;


parameter S0 = 3'b000;
parameter S1 = 3'b001;
parameter S2 = 3'b010;
parameter S3 = 3'b011;
parameter S4 = 3'b100;
parameter S5 = 3'b101;

reg [3-1:0] next_state;

//seq
always @(posedge clk) begin
    if(!rst_n) 
        state <= S0;
    else
        state <= next_state;
end

//comb
always @(*) begin
case (state)
    S0: next_state = in? S2:S0;
    S1: next_state = in? S4:S0;
    S2: next_state = in? S1:S5;
    S3: next_state = in? S2:S3;
    S4: next_state = in? S4:S2;
    default: next_state = in? S4:S3;
    //this determines the state before reset
    //but we can just ignore that 
endcase

//out determined by current state & input
case (state)
    S0: out = in?1'b1:1'b0;
    S1: out = 1'b1;
    S2: out = in?1'b0:1'b1;
    S3: out = in?1'b0:1'b1;
    S4: out = 1'b1;
    default: out = 1'b0; //s5
endcase
end


endmodule
