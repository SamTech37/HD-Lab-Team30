`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2024 06:29:14 PM
// Design Name: 
// Module Name: Lab2_Team30_Decode_And_Execute_fpga
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


module Lab2_Team30_Decode_And_Execute_fpga(rs, rt, sel, LEDout, an);
    input [3:0] rs, rt;
    input [2:0] sel;
    output reg [6:0] LEDout;
    output [3:0] an;
    and a1(an[3], 1, 1);
    and a2(an[2], 1, 1);
    and a3(an[1], 1, 1);
    and a4(an[0], 0, 0);
    wire [3:0] rd;
    Decode_And_Execute DAE1(rs, rt, sel, rd);
    always @(*)
    begin
        case(rd)
        4'b0000: LEDout = 7'b0000001; // "0"     
        4'b0001: LEDout = 7'b1001111; // "1" 
        4'b0010: LEDout = 7'b0010010; // "2" 
        4'b0011: LEDout = 7'b0000110; // "3" 
        4'b0100: LEDout = 7'b1001100; // "4" 
        4'b0101: LEDout = 7'b0100100; // "5" 
        4'b0110: LEDout = 7'b0100000; // "6" 
        4'b0111: LEDout = 7'b0001111; // "7" 
        4'b1000: LEDout = 7'b0000000; // "8"     
        4'b1001: LEDout = 7'b0000100; // "9" 
        4'b1010: LEDout = 7'b0001000; // "A" 
        4'b1011: LEDout = 7'b1100000; // "b" 
        4'b1100: LEDout = 7'b1110010; // "c" 
        4'b1101: LEDout = 7'b1000010; // "d" 
        4'b1110: LEDout = 7'b0110000; // "E" 
        4'b1111: LEDout = 7'b0111000; // "F" 
        default: LEDout = 7'b0000001; // "0"
        endcase
    end
endmodule
