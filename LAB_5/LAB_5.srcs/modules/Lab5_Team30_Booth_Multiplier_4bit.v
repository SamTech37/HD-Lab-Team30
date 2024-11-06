`timescale 1ns/1ps 

//this is a bonus question
module Booth_Multiplier_4bit(clk, rst_n, start, a, b, p);
input clk;
input rst_n; 
input start;
input signed [3:0] a, b;
output signed [7:0] p;

reg [7:0] result
reg [3:0] num_a, num_b;
reg [2-1:0] state, next_state;
reg cnt; //output the result for 2 cycles


parameter WAIT = 2'b00;
parameter CAL = 2'b01;
parameter FINISH = 2'b10;

always @(posedge clk) begin
    if (!rst_n) begin
        state <= WAIT;
        cnt <= 1'b0;
    end
    else begin
    state <= next_state;
        case(state) 
            CAL: begin
                
                cnt <= 1'b0;
                cnt <= cnt+1'b1
            end
            FINISH: begin
                num_a <= num_a;
                num_b <= num_b;
                cnt<=cnt+1'd1;
            end
            default: begin //WAIT
                num_a <= start ? a : num_a;
                num_b <= start ? b : num_b;
                cnt <= 1'b0;
            end
endcase

end

end 

//comb
always @(*) begin
case(state) 
    CAL: begin
        next_state = /////isDone ? FINISH : CAL;
        result = 16'd0;
    end
    FINISH: begin
        next_state = (cnt == 1'b1) ?  WAIT : FINISH;
        if(num_a==0) result = num_b;
        else begin
            if(num_b==0) result = num_a;
            else result = 16'd0;
        end
    end
    default: begin //WAIT
        next_state = start ? CAL : WAIT;
        result = 16'd0;
    end
endcase
end

endmodule




////////////////////////////////
always @(posedge clk) begin
if (!rst_n) begin
    state <= WAIT;

    done <= 1'b0;
    gcd <= 16'd0;
end
else begin
state <= next_state;
case(state) 
    CAL: begin

    end
    FINISH: begin
        num_a <= num_a;
        num_b <= num_b;
        cnt<=cnt+1'd1;
        done <= 1'b1;
        gcd <= result;
    end
    default: begin //WAIT
        num_a <= start ? a : num_a;
        num_b <= start ? b : num_b;
        cnt <= 1'b0;
        done <= 1'b0;
        gcd <= 16'd0;
    end
endcase
// $display("state = %d,num_a = %d, num_b = %d",state, num_a, num_b);//comment this out before submitting
end

end 

//comb
always @(*) begin
case(state) 
    CAL: begin
        next_state = isDone ? FINISH : CAL;
        result = 16'd0;
    end
    FINISH: begin
        next_state = (cnt == 1'b1) ?  WAIT : FINISH;
        //assign p to result
    end
    default: begin //WAIT
        next_state = start ? CAL : WAIT;
        result = 16'd0;
    end
endcase
end