`timescale 1ns/1ps

module Many_To_One_LFSR(clk, rst_n, out);
input clk;
input rst_n;
output reg [8-1:0] out;


//seq
always @(posedge clk) begin
    if(!rst_n)
        out <= 8'b1011_1101; //reset value
    else begin
        out[0] <= (out[1]^out[2])^(out[3]^out[7]);
        out[7:1] <= out[6:0];
    end
end


endmodule

