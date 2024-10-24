`timescale 1ns/1ps

//16x8bit CAM
module Content_Addressable_Memory(clk, wen, ren, din, addr, dout, hit);
input clk;
input wen, ren;
input [7:0] din;
input [3:0] addr;//address to write
output [3:0] dout;//the largest address read, if hit
output hit;//isDin in CAM



wire [1:0]sub_cam;//which sub_cam to write
wire [1:0]sub_addr;
assign sub_cam = addr[3:2];
assign sub_addr = addr[1:0];
wire sub_hit[3:0];
wire [1:0] sub_out [3:0];//2-bit wires, 4 of them

CAM_4x8bit cam0(clk,(wen && sub_cam==2'b00),ren,din,sub_addr,sub_out[0],sub_hit[0]);
CAM_4x8bit cam1(clk,(wen && sub_cam==2'b01),ren,din,sub_addr,sub_out[1],sub_hit[1]);
CAM_4x8bit cam2(clk,(wen && sub_cam==2'b10),ren,din,sub_addr,sub_out[2],sub_hit[2]);
CAM_4x8bit cam3(clk,(wen && sub_cam==2'b11),ren,din,sub_addr,sub_out[3],sub_hit[3]);

assign hit = sub_hit[0]||sub_hit[1]||sub_hit[2]||sub_hit[3];
assign dout = sub_hit[3]? {2'b11,sub_out[3]} : 
              sub_hit[2]? {2'b10,sub_out[2]} :   
              sub_hit[1]? {2'b01,sub_out[1]} :
              sub_hit[0]? {2'b00,sub_out[0]} : 4'b0000; 

endmodule

/*submodules used*/

module CAM_4x8bit(clk, wen, ren, din, addr, dout, hit);
input clk;
input wen, ren;
input [7:0] din;
input [1:0] addr;
output reg [1:0] dout;//the largest address read, if hit
output reg hit;

reg [8-1:0] mem [4-1:0]; // 4 entries of 8-bit 

parameter dont_care = 2'b00;
wire eq[4-1:0];
assign eq[0] = (mem[0]===din); //use strict equality since mem might be empty (8'bx)
assign eq[1] = (mem[1]===din);
assign eq[2] = (mem[2]===din);
assign eq[3] = (mem[3]===din);

wire next_hit;
wire [1:0] next_read; 
assign next_hit = eq[0]||eq[1]||eq[2]||eq[3];
assign next_read = (eq[3])? 2'b11: (eq[2])? 2'b10 : (eq[1])? 2'b01 : (eq[0])? 2'b00 : dont_care;
//this is more readable than a bunch of if-else


//seq
always @(posedge clk) begin 
if(ren) begin //read has higher priority
    dout <= next_read;
    hit <= next_hit;
end
else begin
    dout <= dont_care;
    hit <= 1'b0;
    if(wen) begin
       mem[addr] <= din; 
    end
    else;//no RW
end
end

endmodule