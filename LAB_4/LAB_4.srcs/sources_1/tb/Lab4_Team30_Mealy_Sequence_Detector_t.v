`timescale 1ns/1ps

module Mealy_Sequence_Detector_T ();
reg clk, rst_n;
reg in;
wire dec;

Mealy_Sequence_Detector  detector(clk, rst_n, in, dec);
endmodule
