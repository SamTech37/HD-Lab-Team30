

`define STOP  3'b000
`define SHARP_LEFT  2'b001
`define SHARP_RIGHT  3'b010
`define LEFT  3'b011
`define RIGHT  3'b100
`define FORWARD  3'b101
`define BACKWARD 3'b110
`define CLOCK_REV 3'b111
`define cur_version  6'd6 //LED to make sure newer iterations are actually programmed to the board

//[TODO]
//LED debug for motor mode(direction)
//charge the battery

module CarTop(
    input clk,
    input rst,
    input echo, //from sonic sensor
    input left_signal, //from tracker sensor
    input right_signal,
    input mid_signal,
    output trig, //to sonic sensor
    output left_motor, //pwm for left motor
    output reg [1:0]left,//spin direction for left motor, = {IN1, IN2}
    output right_motor,
    output reg [1:0]right,// {IN3,IN4}
    output wire [5:0]version
);
    

    wire [2:0] state;
    wire reset, rst_db, stop;
    debounce d0(.pb_debounced(rst_db), .pb(rst), .clk(clk));
    onepulse d1(.PB_debounced(rst_db), .clk(clk), .PB_one_pulse(reset));
    assign version = `cur_version;

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
        .stop(stop)
    );
    
    tracker_sensor C(
        .clk(clk), 
        .reset(reset), 
        .left_signal(left_signal), 
        .right_signal(right_signal),
        .mid_signal(mid_signal), 
        .state(state)
       );
       
    // control motor direction (i.e. forward/backward spinning)
    always @(*) begin
        
        if(stop) {left, right} = 4'b0000; //stop
        else begin //go forward
            if(state == `BACKWARD) {left,right} = 4'b0101;
            else {left,right} = 4'b1010; //turning and whatnot should go forward
            
            //rotation
        end
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

