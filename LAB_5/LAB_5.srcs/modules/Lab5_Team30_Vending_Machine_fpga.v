`timescale 1ns/1ps

module Vending_Machine_FPGA (clk,btnL,btnR,btnC,btnD,btnU,an,outSeg,outLED);
input clk;
input btnL,btnR,btnC,btnD,btnU;

//use keyboard A,S,D,F for selecting the item
output [3:0] an; // set as 4'b1000;
output [6:0] outSeg;//7 seg
output [3:0] outLED;//LD3~LD0


endmodule

module Vending_Machine_FSM (clk, rst_n);
input clk, rst_n;

reg [8:0] money;

endmodule