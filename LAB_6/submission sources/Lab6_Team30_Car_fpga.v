`timescale 1ns/1ps

`define STOP  3'b000
`define SHARP_LEFT  3'b001
`define SHARP_RIGHT  3'b010
`define LEFT  3'b011
`define RIGHT  3'b100
`define FORWARD  3'b101
`define BACKWARD 3'b110
`define TRANSITION 3'b111 //not used actually
`define cur_version  6'd21 //LED to make sure newer iterations are actually programmed to the board

module CarTop(
    input clk,
    input rst,
    input echo, //from sonic sensor
    input left_signal, //from tracker sensor
    input right_signal,
    input mid_signal,
    input sonic_en, // to turn on/off the sonic
    input tracker_en,
    output trig, //to sonic sensor
    output left_motor, //pwm for left motor
    output reg [1:0]left,//spin direction for left motor, = {IN1, IN2}
    output right_motor,
    output reg [1:0]right,// {IN3,IN4}
    output wire [5:0] version,
    output wire [1:0]left_LED,
    output wire [1:0]right_LED,
    output wire [6:0] display,
    output wire [3:0] digit
);
    

    wire [2:0] state;
    wire reset, rst_db, stop;
    wire [19:0] distance;
    debounce d0(.pb_debounced(rst_db), .pb(rst), .clk(clk));
    onepulse d1(.PB_debounced(rst_db), .clk(clk), .PB_one_pulse(reset));
    assign version = `cur_version;
    assign left_LED = left;
    assign right_LED = right;

    motor A(
        .clk(clk),
        .rst(reset),
        .mode(state),
        .pwm({left_motor, right_motor})
    );

    sonic_top B(
        .clk(clk), 
        .rst(reset), 
        .Echo(echo), 
        .Trig(trig),
        .stop(stop),
        .distance(distance)
    );
    
    tracker_sensor C(
        .clk(clk), 
        .reset(reset), 
        .left_signal(left_signal), 
        .right_signal(right_signal),
        .mid_signal(mid_signal), 
        .state(state)
       );
       
   car_SevenSegment SS(
        .display(display),
        .digit(digit),//the rightmost 3 digits
        .distance(distance),
        .rst(rst), //active high
        .clk(clk)
    );
    // control motor direction (i.e. forward/backward spinning)
    always @(*) begin
        
        if(stop && sonic_en) {left, right} = 4'b1111; //stop has highest priority
        else begin 
            if(!tracker_en) {left,right}=4'b1010; //forward
            else begin
                case(state)
                `FORWARD, `LEFT, `RIGHT:
                    {left,right} = 4'b1010;
                `SHARP_LEFT:
                    {left,right} = 4'b0110;
                `SHARP_RIGHT:
                    {left,right} = 4'b1001;
                `BACKWARD:
                    {left,right} = 4'b0101;
                `TRANSITION, `STOP:
                    {left,right} = 4'b1111;
                default: 
                    {left,right} = 4'b1010;
                endcase
            end

        end
        
        // if({left, right} == 4'b1111) begin
        //     {left, right} = 4'b1010;
        // end
    end


endmodule

module debounce (pb_debounced, pb, clk);
    output pb_debounced; 
    input pb;
    input clk;
    reg [4:0] DFF;
    
    always @(posedge clk) begin
        DFF[4:1] <= DFF[3:0];
        DFF[0] <= pb; 
    end
    assign pb_debounced = (&(DFF)); 
endmodule

module onepulse (PB_debounced, clk, PB_one_pulse);
    input PB_debounced;
    input clk;
    output reg PB_one_pulse;
    reg PB_debounced_delay;

    always @(posedge clk) begin
        PB_one_pulse <= PB_debounced & (! PB_debounced_delay);
        PB_debounced_delay <= PB_debounced;
    end 
endmodule

// motor

//speed of the main wheel
parameter FAST = 10'd1023;
// parameter MID = 10'd800;
// parameter SLOW = 10'd600;

//the speed difference for turning
parameter TURN = 10'd150;
// parameter SHARP_TURN = 10'd300;

module motor(
    input clk,
    input rst,
    input [2:0]mode,
    output  [1:0]pwm
);

    reg [9:0]next_left_motor, next_right_motor;
    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;

    motor_pwm m0(clk, rst, left_motor, left_pwm);
    motor_pwm m1(clk, rst, right_motor, right_pwm);
    
    always@(posedge clk)begin
        if(rst)begin
            left_motor <= 10'd0;
            right_motor <= 10'd0;
        end else begin
            left_motor <= next_left_motor;
            right_motor <= next_right_motor;
        end
    end
    
    // control motor speed
    always @(*) begin
        case(mode)
            `STOP:
                begin
                    next_left_motor = 10'd0;
                    next_right_motor = 10'd0;
                end
            `LEFT:
                begin
                    next_left_motor = FAST - TURN;
                    next_right_motor = FAST;
                end
            `RIGHT:
                begin
                    next_left_motor = FAST;
                    next_right_motor = FAST - TURN;
                end
            `SHARP_LEFT: //rotation by setting both motors' direction opposite, but same speed
                begin
                    next_left_motor = FAST;
                    next_right_motor = FAST;
                end
            `SHARP_RIGHT:
                begin
                    next_left_motor = FAST;
                    next_right_motor = FAST;
                end
            `TRANSITION:
                begin
                    next_left_motor = 10'd0;
                    next_right_motor = 10'd0;
                end
            `BACKWARD,`FORWARD:
                begin
                    next_left_motor = FAST;
                    next_right_motor = FAST;
                end
            
        endcase
    end


    assign pwm = {left_pwm, right_pwm};
endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
	output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty
module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 32'd100_000_000 / freq;
    //duty / 1024 = duty cycle, max 40%
    wire [31:0] count_duty = count_max * duty / 32'd1024; 
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 32'b0;
            PWM <= 1'b0;
        end else if (count < count_max) begin
            count <= count + 32'd1;
            if(count < count_duty)
                PWM <= 1'b1;
            else
                PWM <= 1'b0;
        end else begin
            count <= 32'b0;
            PWM <= 1'b0;
        end
    end
endmodule


// tracker_sensor

module tracker_sensor(clk, reset, left_signal, right_signal, mid_signal, state);
    input clk;
    input reset;
    input left_signal, right_signal, mid_signal; //low when detected blackline, else high
    output reg [2:0] state;

    wire left, right, mid;
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
        end else if(!left && !right && !mid) begin
            next_last_state = last_state;
            if(last_state == `LEFT) next_state = `SHARP_LEFT;
            else if(last_state == `RIGHT) next_state = `SHARP_RIGHT;
            //next_state = `BACKWARD;
        end else begin
            next_last_state = `FORWARD;
            next_state = `FORWARD;
        end
    end
endmodule



// sonic sensor
module sonic_top(clk, rst, Echo, Trig, stop, distance);
	input clk, rst, Echo;
	output Trig, stop;
    output [19:0] distance; //for 7 segments display

    wire [19:0] distance;
	wire[19:0] dis; //20-bit distance, unit = 0.1mm
	wire[19:0] d; //why there si a d??
    wire clk1M;
	wire clk_2_17;

    div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));

    // [Done] calculate the right distance to trig stop(triggered when the distance is lower than 40 cm)
    parameter StopDistance = 20'd5650; //4000 * 0.1 mm = 40cm, add a buffer distance (2000) to brake
    assign stop = (dis <= StopDistance) ? 1'b1 : 1'b0;
    assign distance = dis / 20'd100;
endmodule

module PosCounter(clk, rst, echo, distance_count); 
    input clk, rst, echo;
    output[19:0] distance_count;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01; 
    parameter S2 = 2'b10;
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[19:0] count, next_count, distance_register, next_distance;
    wire[19:0] distance_count; 

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 1'b0;
            echo_reg2 <= 1'b0;
            count <= 20'b0;
            distance_register <= 20'b0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            count <= next_count;
            distance_register <= next_distance;
            curr_state <= next_state;
        end
    end

    always @(*) begin
        case(curr_state)
            S0: begin
                next_distance = distance_register;
                if (start) begin
                    next_state = S1;
                    next_count = count;
                end else begin
                    next_state = curr_state;
                    next_count = 20'b0;
                end 
            end
            S1: begin
                next_distance = distance_register;
                if (finish) begin
                    next_state = S2;
                    next_count = count;
                end else begin
                    next_state = curr_state;
                    next_count = (count > 20'd600_000) ? count : count + 1'b1;
                end 
            end
            S2: begin
                next_distance = count;
                next_count = 20'b0;
                next_state = S0;
            end
            default: begin
                next_distance = 20'b0;
                next_count = 20'b0;
                next_state = S0;
            end
        endcase
    end

    assign distance_count = distance_register * 20'd100 / 20'd58; 
    assign start = echo_reg1 & ~echo_reg2;  
    assign finish = ~echo_reg1 & echo_reg2; 
endmodule

module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 24'b0;
            trig <= 1'b0;
        end
        else begin
            count <= next_count;
            trig <= next_trig;
        end
    end

    always @(*) begin
        next_trig = trig;
        next_count = count + 1'b1;
        if(count == 24'd999)
            next_trig = 1'b0;
        else if(count == 24'd9999999) begin
            next_trig = 1'b1;
            next_count = 24'd0;
        end
    end
endmodule

module div(clk ,out_clk);
    input clk;
    output out_clk;
    reg out_clk;
    reg [6:0]cnt;
    
    always @(posedge clk) begin   
        if(cnt < 7'd50) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b1;
        end 
        else if(cnt < 7'd100) begin
	        cnt <= cnt + 1'b1;
	        out_clk <= 1'b0;
        end
        else if(cnt == 7'd100) begin
            cnt <= 7'b0;
            out_clk <= 1'b1;
        end
        else begin 
            cnt <= 7'b0;
            out_clk <= 1'b1;
        end
    end
endmodule


// 7-segment display
module car_SevenSegment(
    output reg [6:0] display,
    output reg [3:0] digit,//the rightmost 3 digits
    input wire [19:0] distance,
    input wire rst, //active high
    input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    wire [3:0] nums [2:0]; //3 digits of decimal

    //don't prepend zeros for digit 2 & 3
    assign nums[0] = distance % 10;//dangerous usage of / and % operator
    assign nums[1] = distance / 10;
    assign nums[2] = distance / 100;

    
    //counter / clock divider
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            clk_divider <= 16'b0;
        end else begin
            clk_divider <= clk_divider + 16'b1;
        end
    end
    
    //display cycle 
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            display_num <= 4'b0000;
            digit <= 4'b1111;
        end else if (clk_divider == 16'hFFFF) begin
            case (digit)
                4'b1110 : begin
                    display_num <= nums[0];
                    digit <= 4'b1101;
                end
                4'b1101 : begin
                    display_num <= nums[1];
                    digit <= 4'b1011;
                end
                4'b1011 : begin 
                    display_num <= nums[2];
                    digit <= 4'b1110;
                end
                default : begin
                    display_num <= nums[0];
                    digit <= 4'b1110;
                end				
            endcase
        end else begin
            display_num <= display_num;
            digit <= digit;
        end
    end
    
    always @ (*) begin
        case (display_num) //decode 4-bit number to 7-segment display postion
            0 : display = 7'b1000000;	//0000
            1 : display = 7'b1111001;   //0001                                                
            2 : display = 7'b0100100;   //0010                                                
            3 : display = 7'b0110000;   //0011                                             
            4 : display = 7'b0011001;   //0100                                               
            5 : display = 7'b0010010;   //0101                                               
            6 : display = 7'b0000010;   //0110
            7 : display = 7'b1111000;   //0111
            8 : display = 7'b0000000;   //1000
            9 : display = 7'b0010000;	//1001
            default : display = 7'b1111111;
        endcase
    end
    
endmodule