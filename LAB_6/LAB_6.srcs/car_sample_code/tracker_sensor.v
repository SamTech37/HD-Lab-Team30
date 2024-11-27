`timescale 1ns/1ps
`include "car_top.v"

module tracker_sensor(clk, reset, left_signal, right_signal, mid_signal, state);
    input clk;
    input reset;
    input left_signal, right_signal, mid_signal; //low when detected blackline, else high
    output reg [2:0] state;

    wire left, right, mid;
    reg have_transition;
    //detect white line
    assign left = left_signal;
    assign right = right_signal;
    assign mid = mid_signal;

    reg [2:0] next_state;
    reg [2:0] last_state; 
    reg [2:0] next_last_state; 
    //if the three signals are all zero, 
    //the car will judge whether turning right or left by the previous turn made

    // [Done] Receive three signals and make your own policy.
    // Hint: You can use output state to change your action.

    always @(posedge clk) begin
        if(reset) begin //active-high reset
            state <= `STOP;
            //start = 0;
        end else begin
            state <= next_state;
            last_state <= next_last_state;
            //start <= next_start;
        end
    end

    //better control policy


    always @(*) begin
        if(left && !right && mid) begin
            next_state = `LEFT;
            next_last_state = `LEFT;
        end else if(!left && right && mid) begin
            next_state = `RIGHT;
            next_last_state = `RIGHT;
        end else if(left && !right && !mid) begin
            next_state = `SHARP_LEFT;
            next_last_state = last_state;
        end else if(!left && right && !mid) begin
            next_state = `SHARP_RIGHT;
            next_last_state = last_state;
        end else if(!left && !right && !mid && !have_transition) begin
            //
            next_last_state = last_state;
            next_state = `TRANSITION;
            have_transition = 1'b1;
            //next_state = `BACKWARD;
        end else if(!left && !right && !mid && have_transition) begin
            //
            next_last_state = last_state;
            have_transition = 1'b1;
            if(last_state == `LEFT) next_state = `SHARP_LEFT;
            else if(last_state == `RIGHT) next_state = `SHARP_RIGHT;
            else next_state = `BACKWARD;
            //next_state = `BACKWARD;
        end else begin
            have_transition = 1'b0;
            next_last_state = `FORWARD;
            next_state = `FORWARD;
        end

        // Add TRANSITION case
        //     else if(!left && !right && !mid && !done) begin
        //     next_state = `TRANSITION;
        //     next_start = (done)? 1'b0: 1'b1;
        // end else if(!left && !right && !mid && done) begin
        //     next_state = `BACKWARD;
        //     next_start = 0;
        // end else if(left && right && mid && !done)begin
        //     next_state = `TRANSITION;
        //     next_start = (done)? 1'b0: 1'b1;
        // end else if(left && right && mid && done) begin
        //     next_state = `FORWARD;
        //     next_start = 0;
        // end else begin
        //     next_state = `FORWARD;
        //     next_start = 0;
        // end

        

    end

    

endmodule
