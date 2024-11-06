`timescale 1ns/1ps

module Vending_Machine_FPGA (
PS2_DATA, PS2_CLK,
clk,btnL,btnR,btnC,btnD,btnU,
display, digit, outLED);

inout wire PS2_DATA;//use keyboard A,S,D,F for selecting the item
inout wire PS2_CLK; //one drink at a time. lock the keys? priority?
input wire clk;
input wire btnL,btnC,btnR,btnD,btnU;
output wire [6:0] display;// set as 4'b1000;
output wire [3:0] digit;
output wire [3:0] outLED;//LD3~LD0



//Vending_Machine_FSM vendor(clk,);

endmodule

module Vending_Machine_FSM (
    input clk,
    input rst,//active high reset, be careful
    input insert_five,
    input insert_ten,
    input insert_fifty,
    output [3:0]drink_avail
     
);


reg [8:0] cash;
parameter MAX = 9'd100;
parameter MIN = 9'd0;
parameter WATER = 9'd20;
parameter OOLONG = 9'd25;
parameter COKE = 9'd30;
parameter COFFEE = 9'd80;

assign drink_avail[0] = cash >= WATER;
assign drink_avail[1] = cash >= OOLONG;
assign drink_avail[2] = cash >= COKE;
assign drink_avail[3] = cash >= COFFEE;




always @(posedge clk) begin 
if(rst) begin
    cash <= MIN;
end

else begin 

end
end


endmodule


module Clock_Divder (
    input clk,
    input rst_n,
    output clk_d
);



endmodule

//Onepulse
module OnePulse (
    output reg signal_single_pulse,
    input wire signal,
    input wire clock
    );
    
    reg signal_delay;

    always @(posedge clock) begin
        if (signal == 1'b1 & signal_delay == 1'b0)
            signal_single_pulse <= 1'b1;
        else
            signal_single_pulse <= 1'b0;
        signal_delay <= signal;
    end
endmodule

//debounce
module Debounce(
    input clk,
    input pb,
    output pb_debounced
);
    
    reg [15:0] DFF;
    
    assign pb_debounced = (DFF == 16'hFFFF);
    always @(posedge clk) begin
        DFF[15:1] <= DFF[14:0];
        DFF[0] <= pb;
    end

endmodule

//concurrent display stuff
module SevenSegDisplay(
    output reg [6:0] display,
    output reg [3:0] digit,//use the rightmost 3 digits
    input wire [4:0] num,
    input wire rst,
    input wire clk
    );
    
    reg [4:0] display_num;
    always @ (posedge clk) begin
        digit <= 4'b1000; 
        display_num <= num;
    end
    
    always @ (*) begin
        case (display_num)
            0 : display = 7'b1000000;	//0000
            1 : display = 7'b1111001;   //0001                                                
            2 : display = 7'b0100100;   //0010                                                
            3 : display = 7'b0110000;   //0011                                             
            4 : display = 7'b0011001;   //0100                                               
            5 : display = 7'b0010010;   //0101                                               
            6 : display = 7'b0000010;   //0110
            7 : display = 7'b1111000;   //0111
            8 : display = 7'b0000000;   //1000
            9 : display = 7'b0010000;	//1001
            default : display = 7'b1111111;//all dim
        endcase
    end
    
endmodule


//keyboard I/O
