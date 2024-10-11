`timescale 1ns/1ps

module Scan_Chain_Design_T(clk, rst_n, scan_in, scan_en, scan_out);
reg clk;
reg rst_n;
reg scan_in;
reg scan_en;
wire scan_out;


Scan_Chain_Design scan(clk, rst_n, scan_in, scan_en, scan_out);

endmodule
