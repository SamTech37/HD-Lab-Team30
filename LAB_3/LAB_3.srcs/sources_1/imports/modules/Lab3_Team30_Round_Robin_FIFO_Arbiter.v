`timescale 1ns/1ps

module Round_Robin_FIFO_Arbiter(clk, rst_n, wen, a, b, c, d, dout, valid);
input clk;
input rst_n;
input [4-1:0] wen;
reg [4-1:0] ren;
input [8-1:0] a, b, c, d;
output reg [8-1:0] dout;
output reg valid;
wire [8-1:0] tdout [4-1:0];
wire error[4-1:0];
reg [8-1:0] fdout;
reg [1:0] count;
wire [1:0] next_count;

//com
assign next_count = count+1'b1;
always @ (*) begin
    case(count)
        2'b00: ren = 4'b0001;
        2'b01: ren = 4'b0010;
        2'b10: ren = 4'b0100;
        2'b11: ren = 4'b1000;
        default: ren = 4'b0001;
    endcase
end

FFIFO_8 f0(.clk(clk), .rst_n(rst_n), .wen(wen[0]), .ren(ren[0]), .din(a), .dout(tdout[0]), .error(error[0]));
FFIFO_8 f1(.clk(clk), .rst_n(rst_n), .wen(wen[1]), .ren(ren[1]), .din(b), .dout(tdout[1]), .error(error[1]));
FFIFO_8 f2(.clk(clk), .rst_n(rst_n), .wen(wen[2]), .ren(ren[2]), .din(c), .dout(tdout[2]), .error(error[2]));
FFIFO_8 f3(.clk(clk), .rst_n(rst_n), .wen(wen[3]), .ren(ren[3]), .din(d), .dout(tdout[3]), .error(error[3]));

//seq

always @ (posedge clk) begin
    //counter

    if(!rst_n) begin
        dout <= 8'b0;
        valid <= 1'b0;
        count <= 2'b0;
    end
    else begin
        count <= next_count;
        $display("count: %d", count);
        //$display("ren1: %d: %x, ren2: %d, ren3: %d, ren4: %d", ren[0], ren[1], ren[2], ren[3]);
        $display("wen1: %d, wen2: %d, wen3: %d, wen4: %d", wen[0], wen[1], wen[2], wen[3]);
        $display("a: %d, b: %d, c: %d, d: %d", tdout[0], tdout[1], tdout[2], tdout[3]);
        if(wen[count] || error[count]) begin

            valid <= 1'b0;
            dout <= 8'b0;
        end
        else begin
            valid <= 1'b1;
            $display("count: %d, tdout[count]: %h", count, fdout);
            dout <= tdout[count];
            $display("read!\n");
        end
    end

end
endmodule

module FFIFO_8(clk, rst_n, wen, ren, din, dout, error);
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
    //write operation(not full)
        if(wen && !full) begin
            FIFO[write_pointer] <= din;
            if(next_write == read_pointer) full <= 1'b1;
            //$display("write_pointer = %d, wp = %d", write_pointer, FIFO[write_pointer-1]);
            write_pointer <= next_write;
            error <= 0;
        end
        //read operation(not empty)
        else if(ren && !(write_pointer == read_pointer && !full) && wen == 1'b0) begin
            $display("read_data: %x", FIFO[read_pointer]);
            dout <= FIFO[read_pointer];
            //$display("ride_pointer = %d, rp = %d", read_pointer, FIFO[read_pointer]);
            read_pointer <= next_read;
            error <= 0;
            full <= 0;
        end
        else if(!wen && !ren) error <= 0;
        else error <= 1;
    end
end
endmodule