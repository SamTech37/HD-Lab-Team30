`timescale 1ns/1ps
module Ripple_Carry_Adder_T();
// I/O signals
reg [8-1:0] a = 8'b0000_0000, b=8'b0000_0000;
reg cin = 1'b0;
wire [8-1:0] sum;
wire cout;
Ripple_Carry_Adder RCA(
    .a(a),
    .b(b),
    .cin(cin),
    .cout(cout),
    .sum(sum)
);
reg error = 1'b0;
initial begin
    //make sure the module works under all cases, bitwise.
    repeat (2**17) begin
        #1
        //raise error if cout and sum doesn't check out
        error = !( a+b+cin === {cout,sum});
        #1
        //next input pattern
        {a,b,cin} = {a,b,cin}+ 1'b1;
    end
    
    #1 $finish;
end
endmodule