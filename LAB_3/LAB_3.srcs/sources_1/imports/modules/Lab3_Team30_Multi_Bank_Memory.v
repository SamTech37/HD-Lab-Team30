`timescale 1ns/1ps

module Multi_Bank_Memory (clk, ren, wen, waddr, raddr, din, dout);
input clk;
input ren, wen;
input [11-1:0] waddr;
input [11-1:0] raddr;
input [8-1:0] din;
output [8-1:0] dout;
wire [2-1:0] sub_raddr;
wire [2-1:0] sub_waddr;
assign sub_radd = raddr[10:9];
assign sub_wadd = waddr[10:9];

Bank_Memory BM0(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b00)),
    .wen(wen && (sub_waddr == 2'b00)),
    //if ren is true, set read_address to address, or set write_address to address
    .waddr(ren ? raddr[6:0] : waddr[6:0]),
    .raddr(ren ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .dout(dout)
);

Bank_Memory BM1(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b01)),
    .wen(wen && (sub_waddr == 2'b01)),
    //if ren is true, set read_address to address, or set write_address to address
    .waddr(ren ? raddr[6:0] : waddr[6:0]),
    .raddr(ren ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .dout(dout)
);

Bank_Memory BM2(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b10)),
    .wen(wen && (sub_waddr == 2'b10)),
    //if ren is true, set read_address to address, or set write_address to address
    .waddr(ren ? radd[6:0] : waddr[6:0]),
    .raddr(ren ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .dout(dout)
);

Bank_Memory BM3(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b11)),
    .wen(wen && (sub_waddr == 2'b11)),
    //if ren is true, set read_address to address, or set write_address to address
    .waddr(ren ? raddr[6:0] : waddr[6:0]),
    .raddr(ren ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .dout(dout)
);

endmodule

//Bank_Memory
module Bank_Memory (clk, ren, wen, waddr, raddr, din, dout);
input clk;
input ren, wen;
input [11-1:0] waddr;
input [11-1:0] raddr;
input [8-1:0] din;
output [8-1:0] dout;

wire [2-1:0] sub_raddr;
wire [2-1:0] sub_waddr;
assign sub_raddr = raddr[8:7];
assign sub_waddr = waddr[8:7];

//Sub_Bank_Memory0
Sub_Bank_Memory SBM0(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b00)),
    .wen(wen && (sub_waddr == 2'b00)),
    //if ren is true, set read_address to address, or set write_address to address
    .addr(ren ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .dout(dout)
);

//Sub_Bank_Memory1
Sub_Bank_Memory SBM1(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b01)),
    .wen(wen && (sub_waddr == 2'b01)),
    //if ren is true, set read_address to address, or set write_address to address
    .addr(ren ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .dout(dout)
);

//Sub_Bank_Memory2
Sub_Bank_Memory SBM2(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b10)),
    .wen(wen && (sub_waddr == 2'b10)),
    //if ren is true, set read_address to address, or set write_address to address
    .addr(ren ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .dout(dout)
);

//Sub_Bank_Memory3
Sub_Bank_Memory SBM3(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b11)),
    .wen(wen && (sub_waddr == 2'b11)),
    //if ren is true, set read_address to address, or set write_address to address
    .addr(ren ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .dout(dout)
);

endmodule

//submodules used
module Sub_Bank_Memory (clk, ren, wen, addr, din, dout);
input clk;
input ren, wen;
input [7-1:0] addr;
input [8-1:0] din;
output reg [8-1:0] dout =8'b0000_0000;

reg [8-1:0] mem [128-1:0]; // 128 words of 8-bit data

//seq block to R/W memory
always @(posedge clk) begin
    if(ren) begin // read has higher priority than write 
        dout <= (mem[addr])? mem[addr] : 8'b0000_0000;
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

