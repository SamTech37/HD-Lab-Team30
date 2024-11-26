`timescale 1ns/1ps
`include "car_top.v"

module tracker_sensor(clk, reset, left_signal, right_signal, mid_signal, state);
    input clk;
    input reset;
    input left_signal, right_signal, mid_signal; //low when detected blackline, else high
    output reg [2:0] state;

    wire left, right, mid;
    //detect black line
//    assign left = ~left_signal;
//    assign right = ~right_signal;
//    assign mid = ~mid_signal;


    //detect white line
    assign left = left_signal;
    assign right = right_signal;
    assign mid = mid_signal;

    reg [2:0] next_state;
    

    // [Done] Receive three signals and make your own policy.
    // Hint: You can use output state to change your action.

    always @(posedge clk) begin
        if(reset) begin //active-high reset
            state <= `STOP;
        end else begin
            state <= next_state;
        end
    end

    //better control policy
    
    always @(*) begin
        if(left && !right && mid) begin
            next_state = `LEFT;
        end else if(!left && right && mid) begin
            next_state = `RIGHT;
        end else if(left && !right && !mid) begin
            next_state = `SHARP_LEFT;
        end else if(!left && right && !mid) begin
            next_state = `SHARP_RIGHT;
        end else if(!left && !right && !mid) begin
            next_state = `BACKWARD;
        end else begin
            next_state = `FORWARD;
        end
        

    end

    

endmodule
