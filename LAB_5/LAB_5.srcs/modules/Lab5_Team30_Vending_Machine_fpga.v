`timescale 1ns/1ps

module Vending_Machine_FPGA (
inout wire PS2_DATA,//use keyboard A,S,D,F for selecting the item
inout wire PS2_CLK, //one drink at a time. lock the keys? priority?
input wire clk,
input wire btnL,
input wire btnC,
input wire btnR,
input wire btnD,
input wire btnU,
output wire [6:0] display,// set as 4'b1000;
output wire [3:0] digit,
output wire [3:0] outLED //LD3~LD0
);


wire btnL_db,btnC_db,btnR_db,btnD_db,btnU_db;
wire insert_five,insert_ten,insert_fifty;
wire reset, clear;
wire rst_n;
//debounce & onepulse for btns
Debounce db1(clk,btnL,btnL_db);
Debounce db2(clk,btnC,btnC_db);
Debounce db3(clk,btnR,btnR_db);
Debounce db4(clk,btnD,btnD_db);
Debounce db5(clk,btnU,btnU_db);

OnePulse op1(.clock(clk),.signal(btnL_db),.signal_single_pulse(insert_five));
OnePulse op2(.clock(clk),.signal(btnC_db),.signal_single_pulse(insert_ten));
OnePulse op3(.clock(clk),.signal(btnR_db),.signal_single_pulse(insert_fifty));
OnePulse op4(.clock(clk),.signal(btnD_db),.signal_single_pulse(clear));
OnePulse op5(.clock(clk),.signal(btnU_db),.signal_single_pulse(reset));


assign rst_n = !reset;




Vending_Machine_FSM vendor(clk, reset, clear, insert_five, insert_ten, insert_fifty, outLED);

endmodule

module Vending_Machine_FSM (
    input clk,
    input rst,//active high reset, be careful
    input clear,
    input insert_five,
    input insert_ten,
    input insert_fifty,
    output [3:0]drink_avail
     
);


reg [8:0] cash, next_cash;
parameter MAX = 9'd100;
parameter MIN = 9'd0;
parameter WATER = 9'd20;
parameter OOLONG = 9'd25;
parameter COKE = 9'd30;
parameter COFFEE = 9'd80;

assign drink_avail[0] = (cash >= WATER);
assign drink_avail[1] = (cash >= OOLONG);
assign drink_avail[2] = (cash >= COKE);
assign drink_avail[3] = (cash >= COFFEE);




//seq
always @(posedge clk) begin 
if(rst) begin
    cash <= MIN;
end
else begin 
    cash <= (next_cash > MAX) ? MAX : next_cash;
end
end

//comb
always @(*) begin
   next_cash = cash + insert_five*5 + insert_ten*10 + insert_fifty*50;
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
        DFF <= {DFF[14:0],pb};
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
