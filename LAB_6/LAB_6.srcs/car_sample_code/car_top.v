`define STOP  2'b00
`define LEFT  2'b01
`define RIGHT  2'b10
`define FORWARD  2'b11
`define cur_version  6'b2

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
    
    wire [1:0] state;
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
    // [DONE] Use left and right to set your motor's spinning direction
    always @(*) begin
        
        if(stop) {left, right} = 4'b0000; //stop
        else begin //go forward
            left[1] = 1'b1;
            left[0] = 1'b0;
            right[1] = 1'b1;
            right[0] = 1'b0;
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

