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
always @(cyc/2) clk = ~clk;
    

initial begin


    #(cyc) $finish;
end

endmodule
