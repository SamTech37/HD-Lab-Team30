`timescale 1ns/1ps

//top layer
module Multi_Bank_Memory (clk, ren, wen, waddr, raddr, din, dout);
input clk;
input ren, wen;
input [11-1:0] waddr;
input [11-1:0] raddr;
input [8-1:0] din;
output reg [8-1:0] dout;

wire [2-1:0] rbank = raddr[10:9];
wire [2-1:0] wbank = waddr[10:9];

parameter dont_care = 8'hab;
wire [8-1:0] out[3:0];
Mem_Bank mb0(clk,(ren && rbank == 2'b00),(wen && wbank == 2'b00),waddr[8:0],raddr[8:0],din,out[0]);
Mem_Bank mb1(clk,(ren && rbank == 2'b01),(wen && wbank == 2'b01),waddr[8:0],raddr[8:0],din,out[1]);
Mem_Bank mb2(clk,(ren && rbank == 2'b10),(wen && wbank == 2'b10),waddr[8:0],raddr[8:0],din,out[2]);
Mem_Bank mb3(clk,(ren && rbank == 2'b11),(wen && wbank == 2'b11),waddr[8:0],raddr[8:0],din,out[3]);


//comb
//always @(*) begin
always @(out[0],out[1],out[2],out[3]) begin
    if (ren) begin
        dout = out[rbank];
    end else begin
        dout = dont_care;
    end
end

endmodule



module Mem_Bank (clk, ren, wen, waddr, raddr, din, dout);
input clk;
input ren, wen;
input [9-1:0] waddr;
input [9-1:0] raddr;
input [8-1:0] din;
output reg [8-1:0] dout;

wire [2-1:0] rsbank = raddr[8:7];
wire [2-1:0] wsbank = waddr[8:7];

//R&W on different sub-banks is allowed
//otherwise, only R

parameter dont_care = 8'hcd;
wire [8-1:0]out[3:0];
Sub_Bank m0(clk,(ren && rsbank == 2'b00),(wen && wsbank==2'b00),waddr[6:0],raddr[6:0],din,out[0]);
Sub_Bank m1(clk,(ren && rsbank == 2'b01),(wen && wsbank==2'b01),waddr[6:0],raddr[6:0],din,out[1]);
Sub_Bank m2(clk,(ren && rsbank == 2'b10),(wen && wsbank==2'b10),waddr[6:0],raddr[6:0],din,out[2]);
Sub_Bank m3(clk,(ren && rsbank == 2'b11),(wen && wsbank==2'b11),waddr[6:0],raddr[6:0],din,out[3]);


//comb
//always @(*) begin
always @(out[0],out[1],out[2],out[3]) begin //only sensitive to change of mem bank outputs
    if (ren) begin
        dout = out[rsbank];
    end else begin
        dout = dont_care;
    end
end

endmodule


module Sub_Bank (clk, ren, wen, waddr, raddr, din, dout);
input clk;
input ren, wen;
input [7-1:0] waddr;
input [7-1:0] raddr; //7-bit memory address for 128 cells
input [8-1:0] din;
output reg [8-1:0] dout;

reg [8-1:0] mem [128-1:0]; //128 words of 8-bit data
parameter dont_care = 8'hef;

//seq
always @(posedge clk) begin
    if(ren) begin //read has higher priority
        dout <= mem[raddr]; //should read x if it hasn't been written
    end else begin
        dout <= dont_care;
        mem[waddr] <= (wen)? din : mem[waddr];
        $display("mem[%h] = %d",waddr,mem[waddr]);
    end
end

endmodule
