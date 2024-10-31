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
always @(cyc/2) clk = ~clk;
    

initial begin


    #(cyc) $finish;
end

endmodule 