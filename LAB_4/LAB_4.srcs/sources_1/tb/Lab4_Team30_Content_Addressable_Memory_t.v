`timescale 1ns/1ps

module Content_Addressable_Memory_T();
reg clk;
reg wen, ren;
reg [7:0] din;
reg [3:0] addr;
wire [3:0] dout;
wire hit;

reg [8-1:0] mem [16-1:0]; // a memory block of 16 lines * 8-bit 

Content_Addressable_Memory CAM(clk, wen, ren, din, addr, dout, hit);

endmodule
