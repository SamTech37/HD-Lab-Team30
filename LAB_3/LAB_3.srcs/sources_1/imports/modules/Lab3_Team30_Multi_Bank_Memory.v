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
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .tdout(tdout0)
);

Bank_Memory BM1( 
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b01)),
    .wen(wen && (sub_waddr == 2'b01)),
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .tdout(tdout1)
);

Bank_Memory BM2(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b10)),
    .wen(wen && (sub_waddr == 2'b10)),
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .tdout(tdout2)
);

Bank_Memory BM3(
    .clk(clk),
    .ren(ren && (sub_raddr == 2'b11)),
    .wen(wen && (sub_waddr == 2'b11)),
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .tdout(tdout3)
);

always @(tdout0, tdout1, tdout2, tdout3) begin
    if(ren)
    case (sub_raddr)
        2'b00: dout = tdout0;
        2'b01: dout = tdout1;
        2'b10: dout = tdout2;
        2'b11: dout = tdout3;
    endcase
    else 
        dout = 0;
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

reg [6:0] addr [3:0];
wire [2-1:0] sub_sub_raddr;
wire [2-1:0] sub_sub_waddr;
wire [8-1:0] fdout0, fdout1, fdout2, fdout3;
assign sub_sub_raddr = raddr[8:7];
assign sub_sub_waddr = waddr[8:7];

//Sub_Bank_Memory0
Sub_Bank_Memory SBM0(
    .clk(clk),
    .ren(ren && (sub_sub_raddr == 2'b00)),
    .wen(wen && (sub_sub_waddr == 2'b00)),
    //if the sub bank need to read, set read_address to address, or set write_address to address
    .addr(addr[0]),
    .din(din),
    .fdout(fdout0)
);

//Sub_Bank_Memory1
Sub_Bank_Memory SBM1(
    .clk(clk),
    .ren(ren && (sub_sub_raddr == 2'b01)),
    .wen(wen && (sub_sub_waddr == 2'b01)),
    //if the sub bank need to read, set read_address to address, or set write_address to address
    .addr(addr[1]),
    .din(din),
    .fdout(fdout1)
);

//Sub_Bank_Memory2
Sub_Bank_Memory SBM2(
    .clk(clk),
    .ren(ren && (sub_sub_raddr == 2'b10)),
    .wen(wen && (sub_sub_waddr == 2'b10)),
    //if the sub bank need to read, set read_address to address, or set write_address to address
    .addr(addr[2]),
    .din(din),
    .fdout(fdout2)
);

//Sub_Bank_Memory3
Sub_Bank_Memory SBM3(
    .clk(clk),
    .ren(ren && (sub_sub_raddr == 2'b11)),
    .wen(wen && (sub_sub_waddr == 2'b11)),
    //if the sub bank need to read, set read_address to address, or set write_address to address
    .addr(addr[3]),
    .din(din),
    .fdout(fdout3)
);

always @(*) begin
    if(ren && wen) begin
        addr[sub_sub_raddr] = raddr[6:0];
        if(sub_sub_raddr != sub_sub_waddr) begin
            addr[sub_sub_waddr] = waddr[6:0];
        end
        else begin
            addr[sub_sub_waddr] = addr[sub_sub_waddr];
        end
    end
    else  if(ren && !wen) begin
       addr[sub_sub_raddr] = raddr[6:0]; 
    end
    else if(!ren && wen) begin
        addr[sub_sub_waddr] = waddr[6:0];
    end
    else begin
        addr[0] = 0;
    end
end

always @(fdout0, fdout1, fdout2, fdout3) begin
    if(ren)
    case (sub_sub_raddr)
        2'b00: tdout = fdout0;
        2'b01: tdout = fdout1;
        2'b10: tdout = fdout2;
        2'b11: tdout = fdout3;
    endcase
    else 
        tdout = 0;
end

endmodule


//submodules used
module Sub_Bank_Memory (clk, ren, wen, addr, din, fdout);
input clk;
input ren, wen;
input [7-1:0] addr;
input [8-1:0] din;
output reg [8-1:0] fdout;

reg [8-1:0] mem [128-1:0]; // 128 words of 8-bit data

//seq block to R/W memory
always @(posedge clk) begin
    if(ren) begin // read has higher priority than write 
        fdout <= mem[addr];
        //$display("raddr = %b, value = %d", addr, (mem[addr])? mem[addr] : 8'b0000_0000);
    end
    else if ((!ren) && wen) begin
        mem[addr] <= din;
        fdout<= 8'b0000_0000;
    end
    else begin
        fdout <= 8'b0000_0000; //no r/w performed
    end
end


//always @(*) 
        //$display("waddr = %b, value = %d", addr, mem[addr]);

endmodule