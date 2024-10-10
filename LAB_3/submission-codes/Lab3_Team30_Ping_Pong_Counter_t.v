`timescale 1ns / 1ps

module Ping_Pong_Counter_T();
// I/O signals
reg clk = 1'b1, rst_n = 1'b1;
reg enable = 1'b1;
wire direction;
wire [4-1:0] out;

//test instance
Ping_Pong_Counter counter(.clk(clk), .rst_n(rst_n), .enable(enable), .direction(direction), .out(out));

// clock generation
parameter cyc = 10;
always#(cyc/2) clk = !clk;



initial begin
    //initialize
    @ (negedge clk)
    rst_n = 1'b0;
    enable = 1'b1;
    @ (negedge clk)
	rst_n = 1'b1;
	
	@ (negedge clk)
	repeat(2**2) begin
    #(cyc * 13) enable = 1'b0;
    #(cyc * 3) enable = 1'b1;
	end
    
    #(cyc) $finish;
end


endmodule
