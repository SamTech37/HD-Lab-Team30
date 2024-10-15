`timescale 1ns/1ps

module FIFO_8(clk, rst_n, wen, ren, din, dout, error);
input clk;
input rst_n;
input wen, ren;
input [8-1:0] din;
output reg [8-1:0] dout;
output reg error;
wire [3-1:0] next_write;
wire [3-1:0] next_read;
reg [3-1:0] write_pointer;
reg [3-1:0] read_pointer;
reg [8-1:0] FIFO [8-1:0];
reg full;
assign next_write = write_pointer+1;
assign next_read = read_pointer+1;

always @(posedge clk) begin
    if(!rst_n) begin
    //reset dout and error to zero, and empty the FIFO
        dout <= 0;
        error <= 0;
        write_pointer <= 0;
        read_pointer <= 0;
        full <= 0;
    end
    else begin
    //$display("write_pointer = %d, read_pointer = %d", write_pointer, read_pointer);
    //read operation(not empty)
        if(ren && !(write_pointer == read_pointer && !full)) begin
            dout <= FIFO[read_pointer];
            //$display("ride_pointer = %d, rp = %d", read_pointer, FIFO[read_pointer]);
            read_pointer <= next_read;
            error <= 0;
            full <= 0;
        end
    //write operation(not full)
        else if(wen && !full && ren == 1'b0) begin
            FIFO[write_pointer] <= din;
            if(next_write == read_pointer) full <= 1'b1;
            //$display("write_pointer = %d, wp = %d", write_pointer, FIFO[write_pointer-1]);
            write_pointer <= next_write;
            error <= 0;
        end
        else if(!wen && !ren) error <= 0;
        else error <= 1;
    end
end
    assign write_next = write_pointer+1;
    assign read_next = read_pointer+1;

endmodule
