`timescale 1ns/1ps

module One_TO_Many_LFSR(clk, rst_n, out);
input clk;
input rst_n;
output reg [8-1:0] out;

//seq
always @(posedge clk) begin
    if(!rst_n)
        out <= 8'b1011_1101; //reset value to bd (hex)
    else begin
        //one to many
        out[2] <= out[7]^out[1];
        out[3] <= out[7]^out[2];
        out[4] <= out[7]^out[3];
        out[7:5] <= out[6:4];
        out[0] <= out[7];
        out[1] <= out[0];

    end
end

endmodule
