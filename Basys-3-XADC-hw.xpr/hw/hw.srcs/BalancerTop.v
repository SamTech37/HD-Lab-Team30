`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 12:42:03 AM
// Design Name: 
// Module Name: BalancerTop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//TODO: add LED indicator for version, to ensure it's correctly programmed  
//TODO: figure out how to use input and XADC IP
module BalancerTop(
    input wire clk, //input clock
    input wire rst_btn, //input reset
    input wire [6-1:0] sw,
    output wire [16-1:0]led,
    output wire motorPWM_x, //for servomotor rotation angle control
    output wire motorPWM_y,
    input wire x_pos_driver, //ground
    input wire x_neg_driver, //power source for touchscreen / input from touchscreen
    input wire y_pos_driver, //ground
    input wire y_neg_driver, //power source for touchscreen / input from touchscreen
    input wire y_ground, //ground for XADC voltage ref
    input wire x_ground,
    output [3:0] an, //7-segment display
    output [6:0] seg,
    output dp
    
    );
    
    reg x_inout_dir, y_inout_dir;//0: input, 1: output
    
    
    assign an = 4'b0000;
    assign seg = 7'b000_1111;
    assign dp = 1'b0;

    //refer to the circuit diagram to understand this
    wire x_volt_input, y_volt_input;
    assign y_volt_input = x_neg_driver; 
    assign x_volt_input = y_neg_driver; 

    //debounce & onepulse 
    // assign y_neg_driver = 1'b1; //high = 3v3
    // assign y_pos_driver = 1'b0;

    reg [10-1:0] motor_duty; // ratio = duty/1000
    always @(posedge clk) begin
        case(sw)
            6'b000001://30
                motor_duty <= 10'd41;
            6'b000010://60
                motor_duty <= 10'd58;
            6'b000100://90
                motor_duty <= 10'd75;
            6'b001000: //120
                motor_duty <= 10'd92;
            6'b010000: //150
                motor_duty <= 10'd109;
            6'b100000: //180 degree
                motor_duty <= 10'd125;
            default:// 0
                motor_duty <= 10'd25;
        endcase

    end

//    TouchscreenDriver tdx(
//        .clk(clk),
//        .reset(),
//        .voltagePWM(PWM1v)
//        //set adequate duty to obtain 1V 
//        //when connected to the touchscreen
//    );


    wire enable;
    wire ready;
    reg [7:0] addr_in;
    //xadc instantiation connect the eoc_out .den_in to get continuous conversion
    //process inputs from resistive touchscreen
    xadc_wiz_0 XADC (
        .daddr_in(addr_in),               // input wire [6 : 0] daddr_in
        .den_in(1'b1),                     // input wire den_in
        .di_in(0),                         // input wire [15 : 0] di_in
        .dwe_in(1'b0),                     // input wire dwe_in
        .dclk_in(clk),                     // input wire dclk_in
        .reset_in(),                       // input wire reset_in
        .vp_in(x_volt_input),              // input wire vp_in
        .vn_in(x_ground),                      // input wire vn_in
        .drdy_out(ready),                  // output wire drdy_out
        //output to led for testing
        .do_out(led),              // output wire [15 : 0] do_out
        .eoc_out(enable),                  // output wire eoc_out
        .alarm_out(),                      // output wire alarm_out
        .busy_out()                        // output wire busy_out
    );

    //switch XADC channels to convert 
    always @(posedge clk) begin
        case(sw[1:0])
        0: addr_in <= 8'h16; // XA1/AD6 
        1: addr_in <= 8'h1e; // XA2/AD14 (x_neg)
        2: addr_in <= 8'h17; // XA3/AD7
        3: addr_in <= 8'h1f; // XA4/AD15 (y_neg )
        endcase
    //         addr_in <= 8'h1e; //read from x_neg
    end

    //PID


    //output to actualizer (servomotor)
    ServomotorPWM pwm_x (
        .clk(clk),
        .reset(),
        .duty(motor_duty),
        .PWM(motorPWM_x)
    );
    ServomotorPWM pwm_y (
        .clk(clk),
        .reset(),
        .duty(motor_duty),
        .PWM(motorPWM_y)
    );
endmodule
