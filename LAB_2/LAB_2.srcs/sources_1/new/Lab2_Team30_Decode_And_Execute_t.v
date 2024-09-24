`timescale 1ns/1ps


module Decode_And_Execute_T();
// I/O signals
reg [4-1:0] rs = 4'b0000, rt = 4'b0000;
reg [3-1:0] sel = 3'b000;
wire [4-1:0] rd;


Decode_And_Execute DnE(
    .rs(rs), .rt(rt), .sel(sel), .rd(rd)  
);

initial begin
    
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