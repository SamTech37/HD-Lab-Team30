`timescale 1ns/1ps

module Crossbar_2x2_4bit(in1, in2, control, out1, out2);
input [4-1:0] in1, in2;
input control;
output [4-1:0] out1, out2;

wire nControl;
wire [4-1:0] t1,t2,t3,t4;

not neg(nControl, control);

Dmux_1x2_4bit d1(in1,t1,t2,control);
Dmux_1x2_4bit d2(in2,t3,t4,nControl);

Mux_1x2_4bit m1(t1,t3,out1,control);
Mux_1x2_4bit m2(t2,t4,out2,nControl);

endmodule

/*
submodules used
*/

module Mux_1x2_4bit(in1,in2,out,sel);
input [4-1:0] in1,in2;
input sel;
output [4-1:0] out;

wire nSel;
wire [4-1:0] t1,t2;

not neg(nSel,sel);

and a0(t1[0],in1[0],nSel);
and a1(t1[1],in1[1],nSel);
and a2(t1[2],in1[2],nSel);
and a3(t1[3],in1[3],nSel);

and a4(t2[0],in2[0],sel);
and a5(t2[1],in2[1],sel);
and a6(t2[2],in2[2],sel);
and a7(t2[3],in2[3],sel);

or or0(out[0],t1[0],t2[0]);
or or1(out[1],t1[1],t2[1]);
or or2(out[2],t1[2],t2[2]);
or or3(out[3],t1[3],t2[3]);
endmodule


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

