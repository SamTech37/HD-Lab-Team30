`timescale 1ns/1ps

module Multi_Bank_Memory (clk, ren, wen, waddr, raddr, din, dout);
    input clk;
    input ren, wen;
    input [11-1:0] waddr;
    input [11-1:0] raddr;
    input [8-1:0] din;
    output reg [8-1:0] dout;

    wire ren0, ren1, ren2, ren3, wen0, wen1, wen2, wen3;
    wire [8-1:0] dout_arr [3:0];

    assign ren0 = ren && (raddr[10:9] == 2'b00);
    assign ren1 = ren && (raddr[10:9] == 2'b01);
    assign ren2 = ren && (raddr[10:9] == 2'b10);
    assign ren3 = ren && (raddr[10:9] == 2'b11);
    assign wen0 = wen && (waddr[10:9] == 2'b00);
    assign wen1 = wen && (waddr[10:9] == 2'b01);
    assign wen2 = wen && (waddr[10:9] == 2'b10);
    assign wen3 = wen && (waddr[10:9] == 2'b11);

    Bank bank0(clk, ren0, wen0, waddr[8:0], raddr[8:0], din, dout_arr[0]);
    Bank bank1(clk, ren1, wen1, waddr[8:0], raddr[8:0], din, dout_arr[1]);
    Bank bank2(clk, ren2, wen2, waddr[8:0], raddr[8:0], din, dout_arr[2]);
    Bank bank3(clk, ren3, wen3, waddr[8:0], raddr[8:0], din, dout_arr[3]);

    always @(dout_arr[0], dout_arr[1], dout_arr[2], dout_arr[3]) begin
        if(ren) begin
            dout = dout_arr[raddr[10:9]];
        end
        else begin
            dout = 8'b0;
        end
    end

endmodule

module Bank (clk, ren, wen, waddr, raddr, din, dout);
    input clk;
    input ren, wen;
    input [9-1:0] waddr;
    input [9-1:0] raddr;
    input [8-1:0] din;
    output reg [8-1:0] dout;

    // addr[3:0] indicates which sub-bank to access
    reg [7-1:0] addr[3:0];
    wire [8-1:0] dout_arr[3:0];
    wire ren0, ren1, ren2, ren3, wen0, wen1, wen2, wen3;

    assign ren0 = ren && (raddr[8:7] == 2'b00);
    assign ren1 = ren && (raddr[8:7] == 2'b01);
    assign ren2 = ren && (raddr[8:7] == 2'b10);
    assign ren3 = ren && (raddr[8:7] == 2'b11);
    assign wen0 = wen && (waddr[8:7] == 2'b00);
    assign wen1 = wen && (waddr[8:7] == 2'b01);
    assign wen2 = wen && (waddr[8:7] == 2'b10);
    assign wen3 = wen && (waddr[8:7] == 2'b11);

    // sb for sub-bank
    Memory sb0(clk, ren0, wen0, addr[0], din, dout_arr[0]);
    Memory sb1(clk, ren1, wen1, addr[1], din, dout_arr[1]);
    Memory sb2(clk, ren2, wen2, addr[2], din, dout_arr[2]);
    Memory sb3(clk, ren3, wen3, addr[3], din, dout_arr[3]);

    always @(*) begin
        if(ren && wen) begin
            addr[raddr[8:7]] = raddr[6:0];
            // If R/W on different memory, OK to do simultaneously
            if(waddr[8:7] != raddr[8:7]) begin
                addr[waddr[8:7]] = waddr[6:0];
            end
            else begin
                addr[waddr[8:7]] = addr[waddr[8:7]];
            end
        end
        else if(ren && !wen) begin
            addr[raddr[8:7]] = raddr[6:0];
        end
        else if(!ren && wen) begin
            addr[waddr[8:7]] = waddr[6:0];
        end
        // If neither R nor W, do nothing
        else begin
            addr[0] = 0;
        end
    end

    always @(dout_arr[0], dout_arr[1], dout_arr[2], dout_arr[3]) begin
        if(ren) begin
            dout = dout_arr[raddr[8:7]];
        end
        else begin
            dout = 8'b0;
        end
    end
endmodule

module Memory (clk, ren, wen, addr, din, dout);
    input clk;
    input ren, wen;
    input [7-1:0] addr;
    input [8-1:0] din;
    output [8-1:0] dout;
    reg [8-1:0] dout;
    reg [8-1:0] myMem [128-1:0];

    always @(posedge clk) begin
        if(ren) begin
            dout <= myMem[addr];
        end 
        else if(wen) begin
            myMem[addr] <= din;
            dout <= 8'b0;
        end 
        else begin
            dout <= 8'b0;
        end
    end
endmodule