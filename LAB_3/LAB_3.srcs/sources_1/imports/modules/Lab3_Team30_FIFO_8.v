`timescale 1ns/1ps

//by Samuel
//PASSED TA's TESTBENCH
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

//alternative implementation
//by Sam
//PASSED our own TESTBENCH

module FIFO_8_alt(clk, rst_n, wen, ren, din, dout, error);
input clk;
input rst_n;
input wen, ren;
input [8-1:0] din;
output reg [8-1:0] dout;
output reg error;

wire full,empty;
reg [3-1:0] rp; //read-pointer
reg [4-1:0] wp;//write-pointer, leave some breathing room
reg [8-1:0] FIFO[8-1:0]; //8 cells of 8-bit data

parameter dont_care = 8'hdc;


assign empty = (rp == wp);
assign full = (wp > 4'b0111);

//seq block
always @(posedge clk) begin
if(!rst_n) begin
    rp <= 0;
    wp <= 0;
    dout <= 0;
    error <= 0;
end else begin
    if(ren) begin
        dout <= (empty)? dont_care : FIFO[rp];
        rp <= (empty)? rp : rp+1;
        error <= empty;
        wp <= wp;
    end 
    
    else begin //not reading
        dout <= dont_care;
        rp <= rp;
        if(wen) begin
            wp <= (full)? wp : wp+1;
            FIFO[wp] <= (full)? dont_care : din;
            error <= full;
        end 
        
        else begin //not writing
            error <= 1'b0;
            wp <= wp;
        end
    end
end  
end

endmodule