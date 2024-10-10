`timescale 1ns/1ps

module FIFO_8(clk, rst_n, wen, ren, din, dout, error);
input clk;
input rst_n;
input wen, ren;
input [8-1:0] din;
output reg [8-1:0] dout;
output reg error;

reg [3-1:0] write_pointer;
reg [3-1:0] read_pointer;
reg [8-1:0] FIFO [8-1:0];

always @(posedge clk) begin
    if(!rst_n) begin
    //reset dout and error to zero, and empty the FIFO
        dout <= 0;
        error <= 0;
        write_pointer <= 0;
        read_pointer <= 0;
    end
    else begin
    $display("write_pointer = %d, read_pointer = %d", write_pointer, read_pointer);
    //read operation(not empty)
        if(ren && write_pointer != read_pointer) begin
            dout <= FIFO[read_pointer];
            //$display("ride_pointer = %d, rp = %d", read_pointer, FIFO[read_pointer]);
            read_pointer <= read_pointer + 1;
            error <= 0;
        end
    //write operation(not full)
        else if(wen && write_pointer != (read_pointer-1'b1) && ren == 1'b0) begin
            FIFO[write_pointer] <= din;
            //$display("write_pointer = %d, wp = %d", write_pointer, FIFO[write_pointer-1]);
            write_pointer <= write_pointer + 1;
            error <= 0;
        end
        else if((wen && write_pointer == (read_pointer-1'b1) && ren == 1'b0) || (ren && write_pointer == read_pointer)) error <= 1;
        else error <= 0;
    end
end
endmodule
