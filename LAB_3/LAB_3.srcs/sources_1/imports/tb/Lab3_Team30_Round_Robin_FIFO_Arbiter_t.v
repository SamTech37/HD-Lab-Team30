`timescale 1ns / 1ps
module Round_Robin_FIFO_Arbiter_T();

// I/O signals
reg clk = 1'b0, rst_n = 1'b0;
reg [4-1:0] wen = 4'b0;
reg [8-1:0] a = 8'b0;
reg [8-1:0] b = 8'b0;
reg [8-1:0] c = 8'b0;
reg [8-1:0] d = 8'b0;
wire [8-1:0] dout;
wire valid;

//test instanceMulti_Bank_Memory MBM1(.clk(clk), .ren(ren), .wen(wen), .waddr(waddr), .raddr(raddr), .din(din), .dout(dout));
Round_Robin_FIFO_Arbiter RRFA1 (.clk(clk), .rst_n(rst_n), .wen(wen), .a(a), .b(b), .c(c), .d(d), .dout(dout), .valid(valid));
// clock generation
parameter cyc = 10;
always#(cyc/2) clk = !clk;

//[TODO]
//ren = 0, wen = 1, write in
//ren = 1, wen = 0, read out
//ren = 1, wen = 1, read and write different memory
//ren = 1, wen = 1, read and write same memory

initial begin

    @ (negedge clk)
    //ren = 0, wen = 1, write in
    //write in four memories
    rst_n = 1'b1;
    wen = 4'b1111;
    a = 8'b01010111;
    b = 8'b00111000;
    c = 8'b00001001;
    d = 8'b00001101;


    @ (negedge clk)
    wen = 4'b1000;
    a = 8'bx;
    b = 8'bx;
    c = 8'bx;
    d = 8'b01010101;


	
	@ (negedge clk) 
    wen = 4'b0100;
    a = 8'bx;
    b = 8'bx;
    c = 8'b10001011;
    d = 8'bx;

	@ (negedge clk)
    wen = 4'b0000;
    a = 8'bx;
    b = 8'bx;
    c = 8'bx;
    d = 8'bx;

    @ (negedge clk)
    wen = 4'b0000;
    a = 8'bx;
    b = 8'bx;
    c = 8'bx;
    d = 8'bx;

    @ (negedge clk)
    wen = 4'b0000;
    a = 8'bx;
    b = 8'bx;
    c = 8'bx;
    d = 8'bx;

    @ (negedge clk)
    wen = 4'b0001;
    a = 8'b00110011;
    b = 8'bx;
    c = 8'bx;
    d = 8'bx;

    @ (negedge clk)
    wen = 4'b0000;
    a = 8'bx;
    b = 8'bx;
    c = 8'bx;
    d = 8'bx;

    @ (negedge clk)
    wen = 4'b0000;
    a = 8'bx;
    b = 8'bx;
    c = 8'bx;
    d = 8'bx;
     #(cyc) $finish;
end
endmodule
