`timescale 1ns/1ps 

// This is a bonus question
// tested
module Booth_Multiplier_4bit(clk, rst_n, start, a, b, p);
input clk;
input rst_n; 
input start;
input signed [3:0] a, b;
output signed [7:0] p;

reg [1:0] state, next_state;
parameter WAIT = 2'b00;
parameter CAL = 2'b01;
parameter FINISH = 2'b10;

reg signed [3:0] num_a, num_b;
wire signed [8:0] A; 
wire signed [8:0] S; 
reg signed [8:0] product;
wire signed [8:0] next_product;
reg [3:0] cnt_CAL, cnt_FIN;

assign next_product = (
    (product[1:0] == 2'b01) ? product+A :
    (product[1:0] == 2'b10) ? product+S : product
) >>> 1;

assign A = {num_a, 5'b00000};
assign S = {~num_a + 1'b1, 5'b00000};
assign p = (state == FINISH) ? product[8:1] : 8'd0;
always @(posedge clk) begin
if (!rst_n) begin
    state <= WAIT;
    num_a <= 4'd0;
    num_b <= 4'd0;
    product <= 9'd0;

    cnt_CAL <= 4'd0;
    cnt_FIN <= 4'd0;
end else begin
    state <= next_state;
    // debugging
    // $display("time = %t,state = %d, cnt_CAL = %d, cnt_FIN = %d",$time,state,cnt_CAL,cnt_FIN);
    // $display("current a = %d, b = %d",num_a,num_b);
    // $display("p = %d, product = %d, next_product=%d",p,product,next_product);
    // $display("");
    case(state)
    CAL: begin
        cnt_CAL <= cnt_CAL + 1'b1;
        cnt_FIN <= 4'd0;
        product <= next_product;
        num_a <= num_a;
        num_b <= num_b;
    end
    FINISH: begin
        cnt_FIN <= cnt_FIN + 1'b1;
        cnt_CAL <= 4'd0;
        product <= product;
        num_a <= num_a;
        num_b <= num_b;
    end
    default: begin //WAIT
        cnt_CAL <= 4'd0;
        cnt_FIN <= 4'd0;
        if(start) begin //fetch and buffer the inputs
            product <= {4'b0000, b, 1'b0};
            num_a <= a;
            num_b <= b; 
        end
        else begin
            product <= product;
            num_a <= num_a;
            num_b <= num_b;
        end

    end
    endcase
end
end


always @(*) begin
    case (state)
        CAL:
            next_state = (cnt_CAL == 3'd3) ? FINISH : CAL;
        FINISH:
            next_state = (cnt_FIN == 3'd1) ? WAIT   : FINISH;
        default: //WAIT
            next_state = start ? CAL : WAIT; 
    endcase
end

endmodule
