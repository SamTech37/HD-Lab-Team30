`timescale 1ns/1ps

module Multi_Bank_Memory (clk, ren, wen, waddr, raddr, din, dout);
input clk;
input ren, wen;
input [11-1:0] waddr;
input [11-1:0] raddr;
input [8-1:0] din;
output reg [8-1:0] dout;
wire [2-1:0] sub_raddr;
wire [2-1:0] sub_waddr;
wire [8-1:0] tdout0, tdout1, tdout2, tdout3;
assign sub_raddr = raddr[10:9];
assign sub_waddr = waddr[10:9];


Bank_Memory BM0(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b00)),
    .wen(wen && (sub_waddr == 2'b00)),
    //if ren is true, set read_address to address, or set write_address to address
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .tdout(tdout0)
);

Bank_Memory BM1(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b01)),
    .wen(wen && (sub_waddr == 2'b01)),
    //if ren is true, set read_address to address, or set write_address to address
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .tdout(tdout1)
);

Bank_Memory BM2(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b10)),
    .wen(wen && (sub_waddr == 2'b10)),
    //if ren is true, set read_address to address, or set write_address to address
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .tdout(tdout2)
);

Bank_Memory BM3(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b11)),
    .wen(wen && (sub_waddr == 2'b11)),
    //if ren is true, set read_address to address, or set write_address to address
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .tdout(tdout3)
);


always @(*) begin
    case (sub_raddr)
        2'b00: dout = tdout0;
        2'b01: dout = tdout1;
        2'b10: dout = tdout2;
        2'b11: dout = tdout3;
        default: dout = 8'b00000000;
    endcase
end

endmodule


//Bank_Memory
module Bank_Memory (clk, ren, wen, waddr, raddr, din, tdout);
input clk;
input ren, wen;
input [11-1:0] waddr;
input [11-1:0] raddr;
input [8-1:0] din;
output reg [8-1:0] tdout;

wire [2-1:0] sub_sub_raddr;
wire [2-1:0] sub_sub_waddr;
assign sub_sub_raddr = raddr[8:7];
assign sub_sub_waddr = waddr[8:7];

//Sub_Bank_Memory0
Sub_Bank_Memory SBM0(
    .clk(clk),
    .ren(ren && (sub_sub_raddr == 2'b00)),
    .wen(wen && (sub_sub_waddr == 2'b00)),
    //if the sub bank need to read, set read_address to address, or set write_address to address
    .addr((sub_sub_raddr == 2'b00) ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .fdout(fdout0)
);

//Sub_Bank_Memory1
Sub_Bank_Memory SBM1(
    .clk(clk),
    .ren(ren && (sub_sub_raddr == 2'b01)),
    .wen(wen && (sub_sub_waddr == 2'b01)),
    //if the sub bank need to read, set read_address to address, or set write_address to address
    .addr((sub_sub_raddr == 2'b01) ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .fdout(fdout1)
);

//Sub_Bank_Memory2
Sub_Bank_Memory SBM2(
    .clk(clk),
    .ren(ren && (sub_sub_raddr == 2'b10)),
    .wen(wen && (sub_sub_waddr == 2'b10)),
    //if the sub bank need to read, set read_address to address, or set write_address to address
    .addr((sub_sub_raddr == 2'b10) ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .fdout(fdout2)
);

//Sub_Bank_Memory3
Sub_Bank_Memory SBM3(
    .clk(clk),
    .ren(ren && (sub_sub_raddr == 2'b11)),
    .wen(wen && (sub_sub_waddr == 2'b11)),
    //if the sub bank need to read, set read_address to address, or set write_address to address
    .addr((sub_sub_raddr == 2'b11) ? raddr[6:0] : waddr[6:0]),
    .din(din),
    .fdout(fdout3)
);

always @(*) begin
    case (sub_sub_raddr)
        2'b00: tdout = fdout0;
        2'b01: tdout = fdout1;
        2'b10: tdout = fdout2;
        2'b11: tdout = fdout3;
        default: tdout = 8'b00000000;
    endcase
end

endmodule


//submodules used
module Sub_Bank_Memory (clk, ren, wen, addr, din, fdout);
input clk;
input ren, wen;
input [7-1:0] addr;
input [8-1:0] din;
output reg [8-1:0] fdout =8'b0000_0000;

reg [8-1:0] mem [128-1:0]; // 128 words of 8-bit data

//seq block to R/W memory
always @(posedge clk) begin
    if(ren) begin // read has higher priority than write 
        fdout <= (mem[addr])? mem[addr] : 8'b0000_0000;
    end
    else if ((!ren) && wen) begin
        mem[addr] <= din;
        fdout<= 8'b0000_0000;
    end
    else begin
        fdout <= 8'b0000_0000; //no r/w performed
    end
end

endmodule

