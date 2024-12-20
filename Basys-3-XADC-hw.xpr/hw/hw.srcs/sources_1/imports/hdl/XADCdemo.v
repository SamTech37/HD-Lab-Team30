`timescale 1ns / 1ps
// code retrieved from 
// https://digilent.com/reference/programmable-logic/basys-3/demos/xadc 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 

// 
// Revision:
// Revision 0.01 - tested this template
// Revision 0.02 - testing XADC input
// Revision 0.03 - testing servomotor control
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 

module XADCdemo(
    input CLK100MHZ,
    input vauxp6,
    input vauxn6,
    input vauxp7,
    input vauxn7,
    input vauxp15,
    input vauxn15,
    input vauxp14,
    input vauxn14,
    input vp_in,
    input vn_in,
    input  [1:0] sw,
    output [15:0] led,
    output [3:0] an,
    output dp,
    output [6:0] seg,

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
    reg [1:0] state = S_IDLE;
    reg [15:0] sseg_data;
	
	//binary to decimal converter signals
    reg b2d_start;
    reg [15:0] b2d_din;
    wire [15:0] b2d_dout;
    wire b2d_done;

    // x,y voltage input (use this directly as coordinates?)
    // converted to 10-bit from JXA port analog input
    reg [10-1:0] x_voltage, y_voltage;
    assign led = x_voltage;

    //servomotor control signals
    reg [10-1:0] motor_duty; // ratio = duty/1000
    
    // +1 to duty = +2 deg rotation
    localparam DEG_0 = 10'd25;
    localparam DEG_30 = 10'd41;
    localparam DEG_60 = 10'd58;//default position
    localparam DEG_90 = 10'd75;
    localparam DEG_120 = 10'd92;
    localparam DEG_150 = 10'd109;
    localparam DEG_180 = 10'd125;


    /* main circuit */

    //xadc instantiation 
    // connect the eoc_out .den_in to get continuous conversion
    xadc_wiz_0  XLXI_7 (
        .daddr_in(Address_in), //addresses can be found in the artix 7 XADC user guide DRP register space
        .dclk_in(CLK100MHZ), 
        .den_in(enable), 
        .di_in(0), 
        .dwe_in(0), 
        .busy_out(),                    
        .vauxp6(vauxp6),
        .vauxn6(vauxn6),
        .vauxp7(vauxp7),
        .vauxn7(vauxn7),
        .vauxp14(vauxp14),
        .vauxn14(vauxn14),
        .vauxp15(vauxp15),
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
        case(sw)
        0: Address_in <= 8'h16; // XA1/AD6
        1: Address_in <= 8'h1e; // XA2/AD14
        2: Address_in <= 8'h17; // XA3/AD7
        3: Address_in <= 8'h1f; // XA4/AD15
        endcase
    end
    
    //led visual dmm              
    always @(posedge(CLK100MHZ)) begin            
        if(ready == 1'b1) begin
            x_voltage <= data[15:6]; 
            //it seems the the leftmost 10 bits  are our desired voltage read
        end else begin
            x_voltage <= x_voltage;
        end
    end


    //output to actualizer (servomotor)
    always @(posedge CLK100MHZ) begin
        //on the left
        //remember to consider the base noise
        // the range should be something like [0.1,0.5]V
        // when lower than 0.1 means nothing is on touchscreen
        if (10'd15 <= x_voltage && x_voltage <= 10'd150) begin
            motor_duty <= DEG_30;
        end else if (10'd450 < x_voltage  ) begin //on the right
            motor_duty <= DEG_90;
        end else begin
            motor_duty <= DEG_60; 
        end
    end
    ServomotorPWM pwm_x (
        .clk(CLK100MHZ),
        .reset(),
        .duty(motor_duty),
        .PWM(motorPWM_x)
    );
    // ServomotorPWM pwm_y (
    //     .clk(CLK100MHZ),
    //     .reset(),
    //     .duty(motor_duty),
    //     .PWM(motorPWM_y)
    // );
    

    /* debug tools */
    //binary to decimal conversion
    always @ (posedge(CLK100MHZ)) begin
        case (state)
        S_IDLE: begin
            state <= S_FRAME_WAIT;
            count <= 'b0;
        end
        S_FRAME_WAIT: begin
            if (count >= 10000000) begin
                if (data > 16'hFFD0) begin
                    sseg_data <= 16'h1000;
                    state <= S_IDLE;
                end else begin
                    b2d_start <= 1'b1;
                    b2d_din <= data;
                    state <= S_CONVERSION;
                end
            end else
                count <= count + 1'b1;
        end
        S_CONVERSION: begin
            b2d_start <= 1'b0;
            if (b2d_done == 1'b1) begin
                sseg_data <= b2d_dout;
                state <= S_IDLE;
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
