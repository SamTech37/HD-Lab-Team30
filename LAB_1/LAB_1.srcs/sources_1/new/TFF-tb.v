`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 07:27:13 PM
// Design Name: 
// Module Name: TFF-tb
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


//testbench for TFF with rst_n
//needs refinement
module T_Flip_Flop_t;
// I/O signals
reg clk = 1'b0;
reg t = 1'b0;
reg rst_n = 1'b0; //initial clear
wire q;
// generate clock pulse
always#(1) clk = ~clk;

Toggle_Flip_Flop TFF(
    .clk(clk), 
    .q(q), 
    .t(t), 
    .rst_n(rst_n)
);
//bruteforce to check all possible states
initial begin
    @(negedge clk) rst_n = 1'b1;
    @(negedge clk) t = 1'b1;
    @(negedge clk) t = 1'b0;
    @(negedge clk) t = 1'b1;
    @(negedge clk) t = 1'b0;
    @(negedge clk) rst_n = 1'b0;//finally, reset
    @(negedge clk) $finish;
end

endmodule
