`timescale 1ns/1ps

module Sliding_Window_Sequence_Detector (clk, rst_n, in, dec);
input clk, rst_n;
input in;
output dec;

reg [2:0] state, next_state;
parameter S0 = 3'b000;
parameter S1 = 3'b001;
parameter S2 = 3'b010;
parameter S3 = 3'b011;
parameter S4 = 3'b100;
parameter S5 = 3'b101;
parameter S6 = 3'b110;
parameter S7 = 3'b111;

//seq
always @(posedge clk) begin
    if(!rst_n) state <= S0;
    else state <= next_state;
end
//comb
always @(*) begin
    case(state)
    S0: next_state = in ? S1:S0;
    S1: next_state = in ? S2:S0;
    S2: next_state = in ? S3:S0;
    S3: next_state = in ? S3:S4;
    S4: next_state = in ? S1:S5;
    S5: next_state = in ? S6:S0;
    S6: next_state = in ? S7:S5;
    S7: next_state = in ? S3:S0;
    default: next_state = in ? S1:S0; //S0
    endcase
end

assign dec = (state == S7) && in;

endmodule 