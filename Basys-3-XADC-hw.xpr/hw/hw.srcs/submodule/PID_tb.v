`timescale 1ns / 1ps

module PID_T();
// I/O signals
reg clk = 1'b0;
reg [15:0] pv = 16'd0;
reg rst = 1'b0;
wire [7:0] out;
wire [15:0] gain;
wire [31:0] temp;

// module PID_Controller (
//     input wire clk,                // Clock signal
//     input wire rst,                // Reset signal
//     input wire signed [15:0] sp,   // Setpoint (desired value)
//     input wire signed [15:0] pv,   // Process variable (measured value)
//     input wire signed [15:0] kp,   // Proportional gain
//     input wire signed [15:0] ki,   // Integral gain
//     input wire signed [15:0] kd,   // Derivative gain
//     output wire  [7:0] out    // Output rotation degree (0~120)
// );

//test instance
PID_Controller PIDC(.clk(clk), .rst(rst), .sp(16'd230), .pv(pv), .kp(16'd1), .ki(0), .kd(0), .out(out), .gain(gain), .temp(temp));
// clock generation
parameter cyc = 10;
always#(cyc/2) clk = !clk;

initial begin
    //initialize
    @ (negedge clk)
    rst = 1'b1;

    @ (negedge clk)
	rst = 1'b0;
	
	@ (negedge clk)
    repeat (2**9) begin
        pv <= pv +1 'b1;
        #(cyc);
    end

    #(cyc * 10) 
    #(cyc) $finish;
end
endmodule
