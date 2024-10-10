`timescale 1ns / 1ps
module Multi_Bank_Memory_T ();
// I/O signals
reg clk = 1'b0, ren = 1'b0, wen = 1'b0;
reg [11-1:0] waddr = 11'b00000000000;
reg [11-1:0] raddr = 11'b00000000000;
reg [8-1:0] din = 8'b00000001;
wire [8-1:0] dout;

//test instance
Multi_Bank_Memory MBM1(.clk(clk), .ren(ren), .wen(wen), .waddr(waddr), .raddr(raddr), .din(din), .dout(dout));

// clock generation
parameter cyc = 10;
always#(cyc/2) clk = !clk;
always#(cyc) din = (din + 1)%8; //add din by 1 every cycle


//[TODO]
//ren = 0, wen = 1, write in
//ren = 1, wen = 0, read out
//ren = 1, wen = 1, read and write different memory
//ren = 1, wen = 1, read and write same memory


initial begin

    @ (negedge clk)
    //ren = 0, wen = 1, write in
    //write in four memories
    wen = 1'b1;
    waddr = 11'b00010000000;
    #(cyc) waddr = 11'b01010000000;
    #(cyc) waddr = 11'b10010000000;
    #(cyc) waddr = 11'b11010000000;


    @ (negedge clk)
    //ren = 1, wen = 0, read out
    //read those two memories
	#(cyc)
    wen = 1'b0;
    ren = 1'b1;
    raddr = 11'b00010000000;
    #(cyc) raddr = 11'b01010000000;


	
	@ (negedge clk) 
    //ren = 1, wen = 1, read and write different memory four times
    #(cyc)
    wen = 1'b1;
    raddr = 11'b10010000000;
    waddr = 11'b00100000001;
    #(cyc)
    raddr = 11'b11010000000;
    waddr = 11'b00110000001;
    #(cyc)
    raddr = 11'b00100000001;
    waddr = 11'b00110000010;

	@ (negedge clk)
    //ren = 1, wen = 1, read and write same memory
    #(cyc)
    raddr = 11'b00110000010;
    waddr = 11'b00110000010;
    #(cyc)
    raddr = 11'b00110000001;
    waddr = 11'b00110000001;
    #(cyc*4)
    #(cyc) $finish;
end
endmodule
