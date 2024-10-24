`timescale 1ns/1ps

module Mealy_Sequence_Detector_T ();
//I/O
reg clk = 1'b0, rst_n=1'b1;
reg in;
wire dec;


Mealy_Sequence_Detector  detector(clk, rst_n, in, dec);

parameter cyc = 10;
always #(cyc/2) clk = ~clk;

reg [0:16-1] test_pattern = 16'b0111_0110_1001_0100;
integer i;

initial begin
    @(negedge clk)
    rst_n=1'b0;
    
    @(negedge clk)
    rst_n=1'b1;
    
    for(i = 0;i < 16;i = i+1)begin
        in = test_pattern[i];
        #(cyc);
    end
    
    #(cyc) $finish;
end

endmodule
