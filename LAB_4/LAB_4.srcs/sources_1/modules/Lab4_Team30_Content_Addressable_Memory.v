`timescale 1ns/1ps

module Content_Addressable_Memory(clk, wen, ren, din, addr, dout, hit);
input clk;
input wen, ren;
input [7:0] din;
input [3:0] addr;
output [3:0] dout;
output hit;

reg [8-1:0] mem [16-1:0]; // a memory block of 16 lines * 8-bit 

endmodule
