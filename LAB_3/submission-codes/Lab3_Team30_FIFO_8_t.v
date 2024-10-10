`timescale 1ns / 1ps

module FIFO_T();
// I/O signals
reg clk = 1'b0, rst_n = 1'b1, wen = 1'b0, ren = 1'b0;
reg [8-1:0]din = 8'b00000001;
wire [8-1:0] dout;
wire error;

//test instance
FIFO_8 FIFO(.clk(clk), .rst_n(rst_n), .wen(wen), .ren(ren), .din(din), .dout(dout), .error(error));
// clock generation
parameter cyc = 10;
always#(cyc/2) clk = !clk;
always#(cyc) din = (din + 1)%8; //add din by 1 every cycle

//what should i test?
//empty or full eroor will become one
//read, write function work, and the error should be zero
//while rst_n == 0, the erorr and dout become zero and memory clear
//ren, wen becomes 1 or 0 simultaneously

initial begin
    //initialize
    @ (negedge clk)
    rst_n = 1'b0;

    @ (negedge clk)
	rst_n = 1'b1;
	
	@ (negedge clk) //for write (4 cycles -> 4 numbers)
    wen = 1'b1;
    #(cyc * 4)

    @ (negedge clk) //for read (4 cycles -> 4 numbers)
    ren = 1'b1;
    wen = 1'b1;
    #(cyc * 5)

    @ (negedge clk) //clear data
    rst_n = 1'b0;

    @ (negedge clk)
    rst_n = 1'b1;
    #(cyc * 2) //now there are no data, but ren is still 1, so the error should be 1
    
    @ (negedge clk)
    ren = 1'b0;
    wen = 1'b1;
    #(cyc * 10) //now the FIFO should memory 10 words(which is too much), and the error become 1
    #(cyc) $finish;
end
endmodule
