`timescale 1ns/1ps

//testbench for 8-bit RCA
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

initial begin
    repeat (2**3) begin
        #1 cin=~cin;
        a = (a << 2) + 1;//right shift 2-bits then add 1
        b = (b << 1) + 1;
    end
    #1 $finish;
end

endmodule