`timescale 1ns/1ps

module Multi_Bank_Memory (clk, ren, wen, waddr, raddr, din, dout);
input clk;
input ren, wen;
input [11-1:0] waddr;
input [11-1:0] raddr;
input [8-1:0] din;
output [8-1:0] dout;

endmodule

//submodules used


module Memory (clk, ren, wen, addr, din, dout);
input clk;
input ren, wen;
input [7-1:0] addr;
input [8-1:0] din;
output reg [8-1:0] dout =8'b0000_0000;

reg [8-1:0] mem [128-1:0]; // 128 words of 8-bit data

//seq block to R/W memory
always @(posedge clk) begin
    if(ren) begin // read has higher priority than write 
        dout <= (mem[addr])? mem[addr]: 8'b0000_0000;
    end
    else if ((!ren) && wen) begin
        mem[addr] <= din;
        dout<= 8'b0000_0000;
    end
    else begin
        dout <= 8'b0000_0000; //no r/w performed
    end
end

endmodule

