`timescale 1ns/1ps

module Greatest_Common_Divisor_T ();
reg clk = 1'b0, rst_n = 1'b1;
reg start;
reg [15:0] a;
reg [15:0] b;
wire done;
wire [15:0] gcd;

// Instantiate the Unit Under Test (UUT)
Greatest_Common_Divisor GCD (
    .clk(clk), 
    .rst_n(rst_n), 
    .start(start), 
    .a(a), 
    .b(b), 
    .done(done), 
    .gcd(gcd)
);

parameter cyc = 10;
always #(cyc/2) clk = ~clk;
    

initial begin
    @(negedge clk)
    rst_n = 1'b0;
    a = 16'd3;
    b = 16'd5;
    start = 1'b1;
    @(negedge clk)
    rst_n = 1'b1;
    a = 16'd10;
    b = 16'd30;
    
    
    #(10*cyc)
    a = 16'd6;
    b = 16'd7;
    start = 1'b1;
    
    #(10*cyc)
    a = 16'd169;
    b= 16'd39;
    
    #(20*cyc)
    a = 16'd0;
    b = 16'd6;
    
    #(3*cyc)
    start = 1'b0;


    #(cyc) $finish;
end

endmodule
