`timescale 1ns/1ps

//need revision
module Round_Robin_FIFO_Arbiter(clk, rst_n, wen, a, b, c, d, dout, valid);
input clk;
input rst_n;
input [4-1:0] wen;
input [8-1:0] a, b, c, d;
output reg [8-1:0] dout;
output reg valid;


parameter dont_care = 8'hed;
reg [4-1:0] ren; //arbiter state
reg [4-1:0] next_read; //next state
reg read_err;

wire [8-1:0] out_a, out_b, out_c, out_d;
wire err_a, err_b, err_c, err_d;
FIFO_8_8bit FIFO_a(clk,rst_n,wen[0],ren[0],a, out_a, err_a);
FIFO_8_8bit FIFO_b(clk,rst_n,wen[1],ren[1],b, out_b, err_b);
FIFO_8_8bit FIFO_c(clk,rst_n,wen[2],ren[2],c, out_c, err_c);
FIFO_8_8bit FIFO_d(clk,rst_n,wen[3],ren[3],d, out_d, err_d);

//comb
always @(*) begin
    case(ren)
    4'b0001: begin
        read_err = wen[0] || err_a;
        next_read = 4'b0010;
    end
    4'b0010:begin
        read_err = wen[1] || err_b;
        next_read = 4'b0100;
    end
    4'b0100: begin
        read_err = wen[2] || err_c;
        next_read = 4'b1000;    
    end
    4'b1000: begin
        read_err = wen[3] || err_d;
        next_read = 4'b0001;
    end
    default: begin
        read_err = 1'b0;
        next_read = 4'b0001;//read a for default
    end
    endcase
end

//seq
always @(posedge clk) begin
    if(!rst_n) begin //reset
        dout <= 8'b0;
        valid <= 1'b0;
        ren <= 4'b1000;
    end
    else begin
        ren <= next_read;
        valid <= !read_err;
        if(read_err) dout<=dont_care;
        else case(ren)
        4'b0001: dout<=out_a;
        4'b0010: dout<=out_b;
        4'b0100: dout<=out_c;
        4'b1000: dout<=out_d;
        default: dout<=dont_care;
        endcase
    
    end
end

endmodule

//submodules
module FIFO_8_8bit(clk, rst_n, wen, ren, din, dout, error);
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