`timescale 1ns/1ps

//passed
// gate level
module Dmux_1x2_4bit(in, out1, out2, sel);
input [3:0] in;
input sel;
output [3:0] out1, out2;
wire nsel;

not neg(nsel,sel);

and a0(out1[0],in[0],nsel);
and a1(out1[1],in[1],nsel);
and a2(out1[2],in[2],nsel);
and a3(out1[3],in[3],nsel);

and a4(out2[0],in[0],sel);
and a5(out2[1],in[1],sel);
and a6(out2[2],in[2],sel);
and a7(out2[3],in[3],sel);
endmodule


module Dmux_1x4_4bit(in, a, b, c, d, sel);
input [4-1:0] in;
input [2-1:0] sel;
output [4-1:0] a, b, c, d;

wire [4-1:0]t1,t2;

Dmux_1x2_4bit d0(in,t1,t2,sel[1]);//choose from ab or cd
Dmux_1x2_4bit d1(t1,a,b,sel[0]);//a or b
Dmux_1x2_4bit d2(t2,c,d,sel[0]);//c or d


endmodule
