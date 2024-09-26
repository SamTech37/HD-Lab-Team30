`timescale 1ns/1ps

module Decode_And_Execute_T();
// I/O signals
reg [4-1:0] rs, rt ;
reg [3-1:0] sel;
wire [4-1:0] rd;

Decode_And_Execute DnE(
    .rs(rs), .rt(rt), .sel(sel), .rd(rd)  
);

initial begin
    rs = 4'b0000;
    rt = 4'b0000;
    sel = 3'b000;
    repeat (4) begin
        
        rs = rs + 3;
        rt = rt + 5;
        
        repeat (2**3) begin
            #1 sel = sel + 1;
        end
    end
    #1 $finish;

end

endmodule

