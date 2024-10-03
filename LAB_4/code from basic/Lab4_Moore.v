`timescale 1ns/1ps

module Moore (clk, rst_n, in, out, state);
input clk, rst_n;
input in;
output reg [2-1:0] out;
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
    S0: next_state = in? S2:S1;
    S1: next_state = in? S5:S4;
    S2: next_state = in? S3:S1;
    S3: next_state = in? S0:S1;
    S4: next_state = in? S5:S4;
    default: next_state = in? S0:S3; //s5 
    //this causes the state before reset to be S3 (in = 0 according to tb)
    //but we can just ignore that 
endcase

//out determined by state
case (state)
    S0: out = 2'b11;
    S1: out = 2'b01;
    S2: out = 2'b11;
    S3: out = 2'b10;
    S4: out = 2'b10;
    default: out = 2'b00; //s5
endcase
end

endmodule
