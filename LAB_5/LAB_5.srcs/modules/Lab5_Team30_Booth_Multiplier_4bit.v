`timescale 1ns/1ps 

// This is a bonus question
module Booth_Multiplier_4bit_ver1(clk, rst_n, start, a, b, p);
    input clk;
    input rst_n; 
    input start;
    input signed [3:0] a, b;
    output reg signed [7:0] p;

    reg [1:0] state, next_state;
    parameter WAIT = 2'b00;
    parameter CAL = 2'b01;
    parameter FINISH = 2'b10;

    reg signed [3:0] num_a, num_b;
    reg signed [8:0] A; //Accumulator
    reg signed [8:0] S; 
    reg signed [8:0] P;
    wire signed [8:0] next_P;
    reg [2:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= WAIT;
            cnt   <= 3'd0;
            num_a <= 4'd0;
            num_b <= 4'd0;
            A     <= 9'd0;
            S     <= 9'd0;
            P     <= 9'd0;
            p     <= 8'd0;
        end else begin
            state <= next_state;
            case (state)
                WAIT: begin
                    cnt <= 3'd0;
                    if (start) begin
                        num_a <= a;
                        num_b <= b;
                        A <= {num_a, 5'b00000};
                        S <= {~num_a + 1'b1, 5'b00000}; 
                        //here P won't get the intended value
                        //since num_b is not set yet
                        //the circuit runs in parallel
                        P <= {5'b0000, num_b, 1'b0};

                    end
                    else begin
                        num_a <= num_a;
                        num_b <= num_b;
                        A <= A;
                        S <= S;
                        P <= P;
                    end
                end
                CAL: begin
                    if (cnt < 3'd4) begin
                        /*case (P[1:0])
                            2'b01: begin
                                P <= P + A;
                            end
                            2'b10: begin
                                P <= P + S;
                            end
                            default: P <= P;
                        endcase*/
                        P <= next_P;
                        cnt <= cnt + 1'b1;
                    end
                end
                FINISH: begin
                    cnt <= cnt + 1'b1;
                    p <= P[8:1]; 
                end
            endcase
        end
    end

    assign next_P = (P[1:0] == 2'b01 ? P+A : (P[1:0] == 2'b10 ? P+S : P)) >>> 1;
   

    always @(*) begin
        case (state)
            WAIT:   next_state = start ? CAL : WAIT;
            CAL:    next_state = (cnt == 3'd4) ? FINISH : CAL;
            FINISH: next_state = (cnt == 3'd2) ? WAIT   : FINISH;
            default: next_state = WAIT;
        endcase
    end

endmodule
