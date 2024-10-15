`timescale 1ns/1ps

module Round_Robin_FIFO_Arbiter(clk, rst_n, wen, a, b, c, d, dout, valid);
input clk;
input rst_n;
input [4-1:0] wen;
input [8-1:0] a, b, c, d;
output [8-1:0] dout;
output valid;
wire [8-1:0] tdout [4-1:0];
wire error[4-1:0];

reg [1:0] count;
wire [1:0] next_count;

//com
assign next_count = count+1;
always @ (*) begin
    case(count)
        00: ren = 4'b0001;
        01: ren = 4'b0010;
        10: ren = 4'b0100;
        11: ren = 4'b1000;
    endcase
end
FIFO_8 f0(clk, rst_n, wen[0], ren[0], din, tdout[0], error[0]);
FIFO_8 f2(clk, rst_n, wen[1], ren[1], din, tdout[1], error[1]);
FIFO_8 f3(clk, rst_n, wen[2], ren[2], din, tdout[2], error[2]);
FIFO_8 f1(clk, rst_n, wen[3], ren[3], din, tdout[3], error[3]);
//seq

always @ (posedge clk) begin
    //counter
    count <= next_count;
    if(!rst_n) begin
        dout <= 8'b0;
        valid <= 1'b0;
        count <= 2'b0;
    end
    else begin

    end

end
endmodule

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
endmodule

