`timescale 1ns/1ps

module Built_In_Self_Test_T(clk, rst_n, scan_en, scan_in, scan_out);
//I/O
reg clk;
reg rst_n;
reg scan_en;
wire scan_in;
wire scan_out;

//test instance
Built_In_Self_Test bist(clk, rst_n, scan_en, scan_in, scan_out);

endmodule
