`timescale 1ns/1ps

//patterns to detect: 0111, 1001, 1110
module Mealy_Sequence_Detector (clk, rst_n, in, dec);
input clk, rst_n;
input in;
output dec;

reg [2:0] state, next_state;
reg [2:0] cnt;

parameter S0 = 3'b000;//initial state
parameter S1 = 3'b001;
parameter S2 = 3'b010;
parameter S3 = 3'b011;
parameter S4 = 3'b100;
parameter S5 = 3'b101;
parameter S6 = 3'b110;//final state
parameter S7 = 3'b111;//final state


//seq
always @(posedge clk) begin
if(!rst_n || cnt==2'b11) begin //reset every 4 clock
    state <= S0;
    cnt <= 2'b00;
end
else begin
    cnt <= cnt + 1'b1;
    state <= next_state;
end
end

//comb
always @(*) 
case (state) //it's a Mealy machine
    S1: next_state = in ? S3:S1 ;
    S2: next_state = in ? S5:S4 ;
    S3: next_state = in ? S6:S4 ;
    S4: next_state = in ? S3:S6 ;
    S5: next_state = in ? S7:S4;
    S6: next_state = S6;
    S7: next_state = S7 ;
    default: next_state = in ? S2: S1 ;//S0
endcase

//output 1 only when the patterns are detected
assign dec = ((state == S6) && in) || ((state == S7) && !in );


endmodule
