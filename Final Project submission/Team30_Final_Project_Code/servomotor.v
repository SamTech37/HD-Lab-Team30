module ServomotorPWM(
    input clk, //input clock
    input reset, //input reset
    input [9:0] duty, //input duty cycle
    output wire PWM //output to pmod
);
    // min 0.5/20 ms 0 degree
    // mid 1.5/20 ms 90 degree
    // max 2.5/20 ms 180 degree

    parameter freq = 32'd50; //PWM frequency;
    // 20ms pulse = 50Hz

    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(freq),
        .duty(duty), 
        .PWM(PWM)
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
    wire [31:0] count_duty = count_max * duty / 32'd1024; 
    //duty / 1024 = duty cycle
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

