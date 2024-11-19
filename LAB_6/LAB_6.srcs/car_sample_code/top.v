module Top(
    input clk,
    input rst,
    input echo, //from sonic sensor
    input left_signal, //from tracker sensor
    input right_signal,
    input mid_signal,
    output trig, //to sonic sensor
    output left_motor, //to motor driver
    output reg [1:0]left,
    output right_motor,
    output reg [1:0]right
);

    wire [1:0] state;
    wire reset, rst_db, stop;
    debounce d0(.pb_debounced(rst_db), .pb(rst), .clk(clk));
    onepulse d1(.PB_debounced(rst_db), .clk(clk), .PB_one_pulse(reset));

    motor A(
        .clk(clk),
        .rst(reset),
        .mode(state),
        .pwm()
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

    always @(*) begin
        // [TO-DO] Use left and right to set your pwm
        //if(stop) {left, right} = ???;
        //else  {left, right} = ???;
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

