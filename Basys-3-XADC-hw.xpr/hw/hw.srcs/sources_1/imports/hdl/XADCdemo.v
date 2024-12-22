`timescale 1ns / 1ps
// template retrieved from 
// https://digilent.com/reference/programmable-logic/basys-3/demos/xadc 
//////////////////////////////////////////////////////////////////////////////////
// 
// Revision:
// Revision 0.01 - tested this template
// Revision 0.02 - testing JXA port XADC input from touchscreen 
// Revision 0.03 - testing servomotor control
// Revision 0.04 - testing PID controller
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 

module BallBalancer2D(
    input CLK100MHZ,
    // JXA port analog input
//    input vauxp6,
    input vauxn6,
    input vauxp7,
    input vauxn7,
    input vauxp15,
    input vauxn15,
    input vauxp14,
    input vauxn14,
    input vp_in, // input for single channel XADC
    input vn_in, // (not used)
    input  [15:0] sw,
    output [15:0] led,
    output [3:0] an,
    output dp,
    output [6:0] seg,
    // touchscreen drivers
    // inouts?
    // input wire x_pos_driver, //ground
     inout wire x_neg_driver, //power source for x-direction / input from y-direction
    // input wire y_pos_driver, //ground
    // inout wire y_neg_driver, //power source for y-direction  / input from x-direction
    
    output wire motorPWM_x, //for servomotor rotation angle control
    output wire motorPWM_y
);

    wire slow_clock; //maybe use 100ns clock cycle in case some calculations takes longer

    //XADC signals
    wire enable;  
    wire ready;
    wire [15:0] data;   
    reg [6:0] Address_in;
	
	//seven segment controller signals
    reg [32:0] count;
    localparam S_IDLE = 0;
    localparam S_FRAME_WAIT = 1;
    localparam S_CONVERSION = 2;
    reg [1:0] b2d_state = S_IDLE;
    reg [15:0] sseg_data;
	
    wire showMode; //0 show voltage, 1 show pid content
    assign showMode = sw[15];

	//binary to decimal converter signals
    reg b2d_start;
    reg [15:0] b2d_din;
    wire [15:0] b2d_dout;
    wire b2d_done;


    //handle inouts
    localparam TOUCH_IDLE = 2'b00;
    localparam TOUCH_X = 2'b01;
    localparam TOUCH_Y = 2'b10;
    reg [1:0] touchscreen_state = TOUCH_X;
    reg [1:0] next_touchscreen_state;

    //adjustable parameters, depends on the output voltage
    parameter [10-1:0] X_max = 10'd460, X_mid = 10'd230, X_min=10'd10;

    //less than X    
    //parameter [10-1:0] Y_max = 10'd460, Y_mid = 10'd230, Y_min;

    // x,y voltage input (use this directly as coordinates?)
    // converted to 10-bit from JXA port analog input
    reg [10-1:0] x_voltage, y_voltage;
    assign led = (touchscreen_state == TOUCH_X) ? x_voltage : y_voltage;

    
    //output to x_neg inout
    assign x_neg_driver = (touchscreen_state == TOUCH_X) ? 1'b1 : 1'bz;
    assign y_neg_driver = (touchscreen_state == TOUCH_Y) ? 1'b1 : 1'bz;
    
    wire vauxp6;
    assign vauxp6 = x_neg_driver;//input from x_neg inout

    //servomotor control signals
    // ratio = duty/1024
    // spare some bits to prevent overflow
    reg [20-1:0] motor_duty_x; 
    reg [20-1:0] motor_duty_y;
    
    // +1 to duty = +2 deg rotation
    localparam DEG_0 = 10'd25;
    localparam DEG_30 = 10'd41;
    localparam DEG_60 = 10'd58;//default position
    localparam DEG_90 = 10'd75;
    localparam DEG_120 = 10'd92;
    localparam DEG_150 = 10'd109;
    localparam DEG_180 = 10'd125;


    /* 
    // main circuit 
    */

    //xadc instantiation 
    // connect the eoc_out .den_in to get continuous conversion
    xadc_wiz_0  XADC_IP (
        .daddr_in(Address_in), //addresses can be found in the artix 7 XADC user guide DRP register space
        .dclk_in(CLK100MHZ), 
        .den_in(enable), 
        .di_in(0), 
        .dwe_in(0), 
        .busy_out(),                    
        .vauxp6(vauxp6), //channel for reading y-direction
        .vauxn6(vauxn6),
        .vauxp7(vauxp7),
        .vauxn7(vauxn7),
        .vauxp14(vauxp14),
        .vauxn14(vauxn14),
        .vauxp15(vauxp15), //channel for reading x-direction
        .vauxn15(vauxn15),
        // .vn_in(vn_in), 
        // .vp_in(vp_in), 
        // .alarm_out(), 
        .do_out(data), 
        //.reset_in(),
        .eoc_out(enable),
        .channel_out(),
        .drdy_out(ready)
    );
    
    always @(posedge(CLK100MHZ)) begin
        case(sw[1:0])
        0: Address_in <= 8'h16; // XA1/AD6
        1: Address_in <= 8'h1e; // XA2/AD14
        2: Address_in <= 8'h17; // XA3/AD7
        3: Address_in <= 8'h1f; // XA4/AD15
        endcase
    end
    
    //led visual dmm              
    always @(posedge(CLK100MHZ)) begin            
        //it seems the leftmost 10 bits are the desired voltage readings
        x_voltage <= (ready && touchscreen_state==TOUCH_X) ? 
                    data[15:6] : x_voltage;

        // y_voltage <= (ready && touchscreen_state==TOUCH_Y) ?
        //             data[15:6] : y_voltage;
    end


    //PID controller
    localparam KP_X = 16'h1;
    localparam KI_X = 16'h0;
    localparam KD_X = 16'h3;
    wire [8-1:0] pid_x_out;
    wire [16-1:0] pid_x_gain;
    PID_Controller pid_x (
    .clk(CLK100MHZ),               
    .rst(),                
    .sp(X_mid),   // Setpoint (desired value)
    .pv(x_voltage),   // Process variable (measured value)
    .kp(KP_X),   // Proportional gain
    .ki(KI_X),   // Integral gain
    .kd(KD_X),   // Derivative gain
    .out(pid_x_out),    // Output rotation degree (0~120)
    .gain(pid_x_gain)
    );

    //output to actualizer (servomotor)
    always @(posedge CLK100MHZ) begin
        //obtain pwm duty from angle
        motor_duty_x <= pid_x_out * 20'd67 / 20'd120 + DEG_0 ;
    end
    ServomotorPWM pwm_x (
        .clk(CLK100MHZ),
        .reset(),
        .duty(motor_duty_x[10-1:0]),
        .PWM(motorPWM_x)
    );
    ServomotorPWM pwm_y (
        .clk(CLK100MHZ),
        .reset(),
        .duty(motor_duty_y[10-1:0]),
        .PWM(motorPWM_y)
    );
    

    /* debug tools */
    //binary to decimal conversion
    always @ (posedge(CLK100MHZ)) begin
        case (b2d_state)
        S_IDLE: begin
            b2d_state <= S_FRAME_WAIT;
            count <= 'b0;
        end
        S_FRAME_WAIT: begin
            if (count >= 10000000) begin
                if (data > 16'hFFD0) begin
                    sseg_data <= 16'h1000;
                    b2d_state <= S_IDLE;
                end else begin
                    b2d_start <= 1'b1;
                    b2d_din <= showMode ? {8'b0,pid_x_out} : data;
                    b2d_state <= S_CONVERSION;
                end
            end else
                count <= count + 1'b1;
        end
        S_CONVERSION: begin
            b2d_start <= 1'b0;
            if (b2d_done == 1'b1) begin
                sseg_data <= b2d_dout;
                b2d_state <= S_IDLE;
            end
        end
        endcase
    end
    
    bin2dec m_b2d (
        .clk(CLK100MHZ),
        .start(b2d_start),
        .din(b2d_din),
        .done(b2d_done),
        .dout(b2d_dout)
    );
      

    
    DigitToSeg segment1(
        .in1(sseg_data[3:0]),
        .in2(sseg_data[7:4]),
        .in3(sseg_data[11:8]),
        .in4(sseg_data[15:12]),
        .in5(),
        .in6(),
        .in7(),
        .in8(),
        .mclk(CLK100MHZ),
        .an(an),
        .dp(dp),
        .seg(seg)
    );
endmodule
