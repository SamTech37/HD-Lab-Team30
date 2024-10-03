`timescale 1ns / 1ps


module Parameterized_Ping_Pong_Counter_T();
// I/O signals
reg clk = 1'b1, rst_n =1'b1;
reg enable = 1'b1;
reg flip = 1'b0;
reg [4-1:0] max = 4'b1001;
reg [4-1:0] min = 4'b0011;
wire direction;
wire [4-1:0] out;

//test instance
Parameterized_Ping_Pong_Counter ppp_counter (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .flip(flip),
    .max(max),
    .min(min),
    .direction(direction),
    .out(out)
);


// clock generation
parameter cyc = 10;
always#(cyc/2)clk = !clk;

//exhaustive test with error raising
reg error = 1'b0;;


//need more rigorous testing

initial begin
    //initialize inputs
    @ (negedge clk)
    rst_n = 1'b0;
    enable = 1'b1;
    @ (negedge clk)
	rst_n = 1'b1;
	
	@ (negedge clk)
	repeat(2**2) begin
    #(cyc * 12) enable = 1'b0;
    #(cyc * 3) enable = 1'b1;
	end
    
    #(cyc) $finish;
end


endmodule
