`timescale 1ns / 1ps


module Parameterized_Ping_Pong_Counter_T();
// I/O signals
reg clk = 1'b1, rst_n =1'b1;
reg enable = 1'b1;
reg flip = 1'b0;
reg [4-1:0] max;
reg [4-1:0] min;
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


//[TODO]                                
//handle enable                         
//handle max & min & out-of-range       
//handle flip                           

initial begin
    //initialize inputs
    @ (negedge clk)
    rst_n = 1'b0;
    enable = 1'b1;
    min = 4'd2;
    max = 4'd10;
    @ (negedge clk)
	rst_n = 1'b1;
	
	//counting up & down
	#(cyc*16)
	max = 4'd9;
	#(cyc*4)
	min = 4'd3;
	
	#(cyc*16)
	//test disable
	enable = 1'b0;
	#(cyc*4) enable = 1'b1;
	
	//test flip
    @ (negedge clk)
	#(cyc) flip = 1'b1;
	#(cyc) flip = 1'b0;
	@ (negedge clk)
	#(cyc*4) flip = 1'b1;
	#(cyc*4) flip = 1'b0;
	
	//test out of range
    @ (negedge clk)
    max = 4'd5;
    min = 4'd9;
    #(cyc*4)
    
    
    #(cyc) $finish;
end

//comb



endmodule
