`timescale 1ns/1ps

module Built_In_Self_Test(clk, rst_n, scan_en, scan_in, scan_out);
input clk;
input rst_n;
input scan_en;
output scan_in;
output scan_out;
wire temp;
assign scan_in = temp;
Many_To_One_LFSRR MTO_LFSR(clk, rst_n, temp);
Scan_Chain_Design SCD(clk, rst_n, temp, scan_en, scan_out);
/*reg [2:0] count;
wire next_count;
assign next_count = count + 1'b1;
always @(posedge clk) begin
    if(!rst_n) count <= 1'b0;
    else begin
    count <= next_count;
    //$display("input[%d] = %d", count, temp);
    end
end*/
endmodule

module Many_To_One_LFSRR(clk, rst_n, fout);
input clk;
input rst_n;
output fout;
reg [8-1:0] out;
assign fout = out[7];

//seq
always @(posedge clk) begin
//$display("fout: %d", fout);
    if(!rst_n)
        out <= 8'b1011_1101; //reset value
    else begin
        out[0] <= (out[1]^out[2])^(out[3]^out[7]);
        out[7:1] <= out[6:0];
    end
end
endmodule


module Scan_Chain_Design(clk, rst_n, scan_in, scan_en, scan_out);
input clk, scan_in, rst_n, scan_en;
output scan_out;
wire [3:0] a, b;
wire [7:0] p;
assign p = a*b;
SDFF SDFF7(clk, rst_n, scan_in, scan_en, p[7], a[3]);
SDFF SDFF6(clk, rst_n, a[3], scan_en, p[6], a[2]);
SDFF SDFF5(clk, rst_n, a[2], scan_en, p[5], a[1]);
SDFF SDFF4(clk, rst_n, a[1], scan_en, p[4], a[0]);
SDFF SDFF3(clk, rst_n, a[0], scan_en, p[3], b[3]);
SDFF SDFF2(clk, rst_n, b[3], scan_en, p[2], b[2]);
SDFF SDFF1(clk, rst_n, b[2], scan_en, p[1], b[1]);
SDFF SDFF0(clk, rst_n, b[1], scan_en, p[0], b[0]);
and(scan_out, 1, b[0]);
endmodule

module SDFF(clk, rst_n, scan_in, scan_en, data ,din);
input clk, rst_n, scan_en, data, scan_in;
output reg din;
reg dinnext;
always @(*) begin
    if(scan_en) dinnext = scan_in;
    else dinnext = data;
end

always @ (posedge clk) begin
    if(!rst_n) din <= 1'b0;
    else din <= dinnext;
end
endmodule