`timescale 1ns/1ps

module Sliding_Window_Sequence_Detector_T ();
//I/O
reg clk = 1'b0, rst_n = 1'b1;
reg in;
wire dec;


//instantiate
Sliding_Window_Sequence_Detector SWSD (
    .clk(clk),
    .rst_n(rst_n),
    .in(in),
    .dec(dec)
);


parameter cyc = 10;
always #(cyc/2) clk = ~clk;
    
reg [0:16-1] test_pattern = 16'b1110_0111_1001_0111;
integer i;

initial begin
    @(negedge clk)
    rst_n=1'b0;
    in = 1'b0;
    
    @(negedge clk)
    rst_n=1'b1;
    
    for(i = 0;i < 16;i = i+1)begin
        in = test_pattern[i];
        #(cyc);
    end
    
    #(cyc) $finish;
end

endmodule 