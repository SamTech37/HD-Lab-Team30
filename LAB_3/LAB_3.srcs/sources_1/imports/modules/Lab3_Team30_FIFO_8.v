`timescale 1ns/1ps

module FIFO_8(clk, rst_n, wen, ren, din, dout, error);
input clk;
input rst_n;
input wen, ren;
input [8-1:0] din;
output reg [8-1:0] dout;
output reg error;
wire [3-1:0] write_next ;
wire [3-1:0] read_next;
reg [3-1:0] write_pointer;
reg [3-1:0] read_pointer;
reg [8-1:0] FIFO [8-1:0];
reg full;


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
    //read operation(not empty = (write_pointer == read_pointer && !full))
        if(ren && !(write_pointer == read_pointer && !full)) begin
            dout <= FIFO[read_pointer];
            //$display("ride_pointer = %d, rp = %d", read_pointer, FIFO[read_pointer]);
            read_pointer <= read_next;
            error <= 0;
            full <= 0;
        end
    //write operation(not full)
        else if(wen && !full && !ren) begin
            FIFO[write_pointer] <= din;
            //$display("write_pointer = %d read_pointer = %d", write_pointer, read_pointer);
            //$display("full = %d", full);
            write_pointer <= write_next;
            if(write_next == read_pointer) full <= 1'b1;
            else full <= full;
            error <= 0;
        end
        else if(!ren && !wen) error <= 0;
        else error <= 1;
    end
end
    assign write_next = write_pointer+1;
    assign read_next = read_pointer+1;

endmodule
