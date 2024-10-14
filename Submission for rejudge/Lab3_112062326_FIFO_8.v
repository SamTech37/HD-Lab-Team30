`timescale 1ns/1ps


module FIFO_8(clk, rst_n, wen, ren, din, dout, error);
input clk;
input rst_n;
input wen, ren;
input [8-1:0] din;
output reg [8-1:0] dout;
output reg error;

wire read_err, write_err;
reg [4-1:0] wp, rp;//write-pointer & read-pointer, leave some breathing room
reg [8-1:0] FIFO[8-1:0]; //8 cells of 8-bit data

parameter dont_care = 8'hef;


assign read_err = (rp == wp);//empty
assign write_err = (wp > 4'b0111);//full

//seq block
always @(posedge clk) begin
    if(!rst_n) begin
        rp <= 4'd0;
        wp <= 4'd0;
        dout <= 8'b0;
        error <= 1'b0;
    end 
    else if(ren) begin //read has higher priority
        if(!read_err) begin
            rp <= rp+1;
            dout <= FIFO[rp];
        end
        else dout <= dont_care;
        error <= read_err;
    end 
    else if (wen) begin
        if (!write_err) begin
            FIFO[wp] <= din;
            wp <= wp+1;
        end
        dout <= dont_care;
        error <= write_err;
    end
    else begin //no RW operations
        rp <= rp;
        wp <= wp;
        dout <= dont_care ;
        error <= 1'b0;
    end
    
end



endmodule
