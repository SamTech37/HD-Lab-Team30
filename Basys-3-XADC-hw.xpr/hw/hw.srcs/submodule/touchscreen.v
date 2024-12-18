//controller for 4-wire resistive touchscreen
module TouchscreenTop(
    input clk, //input clock
    input reset, //input reset
    //pmod inout?
    input  [10-1:0] voltage_x, //input voltage from x axis
    input  [10-1:0] voltage_y, //input voltage from y axis
    output [10-1:0] x_coord,
    output [10-1:0] y_coord,
    output reg valid
);
    //detect ball position on touchscreen
    //by reading reduced voltage from x & y axis

    //take the average of multiple readings to reduce measurement error
    reg [15-1:0] x_coord_accu, y_coord_accu;
    assign x_coord = x_coord_accu >> 4;
    assign y_coord = y_coord_accu >> 4;


    reg [1:0] state, next_state;
    parameter IDLE = 2'b00;
    parameter READ_X = 2'b10;
    parameter READ_Y = 2'b01;

    //FSM
    always @(posedge clk) begin
        if(reset) begin
            state <= IDLE;
            valid <= 1'b0;
        end else begin
            state <= next_state;

        end
    end

    always @(*) begin
        case(state) 
            READ_X:;
            READ_Y:;
            default:;
        endcase
    end

endmodule


module TouchscreenDriver (
    input clk,
    input reset,
    output voltagePWM
    //set duty = 30.3% to obtain 1V
    // 310/1024 = 30.3%
);
    //outputing 1v
    //would result in y-read 0.55v, x-read 0.77v
    //we need to account for the min resistance of the board, so maybe output 1v2~1v5
    
    parameter DUTY = 10'd402; //this will make vx = [0,1], vy=[0,0.7~]
    parameter FREQ = 10'd60; //60HZ

    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(FREQ),
        .duty(DUTY), 
        .PWM(voltagePWM)//output ~1v3
    );
endmodule