`timescale 1ns/1ps

module Greatest_Common_Divisor (clk, rst_n, start, a, b, done, gcd);
input clk, rst_n;
input start;
input [15:0] a;
input [15:0] b;
output reg done;
output reg [15:0] gcd;

reg [16-1:0] result, num_a, num_b;
reg [2-1:0] state, next_state;
reg cnt; //output the result for 2 cycles
wire isDone;

parameter WAIT = 2'b00;
parameter CAL = 2'b01;
parameter FINISH = 2'b10;


assign isDone = (num_a == 16'd0)||(num_b==16'd0);

//seq
always @(posedge clk) begin
if (!rst_n) begin
    state <= WAIT;
    cnt <= 1'b0;
    done <= 1'b0;
    gcd <= 16'd0;
end
else begin
state <= next_state;
case(state) 
    CAL: begin
        if (num_a > num_b) begin
            num_a <= num_a - num_b;
            num_b <= num_b;
        end
        else begin
            num_b <= num_b - num_a;
            num_a <= num_a;
        end
        cnt <= 1'b0;
        done <= 1'b0;
        gcd <= 16'd0;
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
$display("state = %d,num_a = %d, num_b = %d",state, num_a, num_b);//comment this out before submitting
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
