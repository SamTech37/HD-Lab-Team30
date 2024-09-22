`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2024 07:27:13 PM
// Design Name: 
// Module Name: Dmux_1x4_4bit-tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//testbench for Dmux_1x4_4bit

module Dmux_1x4_4bit_t;

// I/O signals
reg [3:0]in = 4'b0001;
reg [1:0]sel = 2'b00;
wire [3:0]a;
wire [3:0]b;
wire [3:0]c;
wire [3:0]d;

Dmux_1x4_4bit d1(
    .in (in),
    .sel (sel),
    .a (a),
    .b (b),
    .c (c),
    .d (d)
);

// uncommment and add "+access+r" to your nverilog command to dump fsdb waveform on NTHUCAD
/*initial begin
      $fsdbDumpfile("DFF.fsdb");
      $fsdbDumpvars;
 end*/

initial begin
    repeat (2 ** 3) begin
        #1 sel = sel + 2'b1;
        in = in + 4'b1;
    end
    #1 $finish;
end

endmodule
