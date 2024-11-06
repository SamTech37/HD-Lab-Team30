`timescale 1ns/1ps

// [TODO]
// add keyboard IO


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

wire [3:0] drink_select;
wire key_A, key_S, key_D, key_F;

wire btnL_db,btnC_db,btnR_db,btnD_db,btnU_db;
wire insert_five,insert_ten,insert_fifty;
wire rst, clear;
//debounce & onepulse for btns
Debounce db1(.clk(clk),.reset(rst),.pb(btnL),.pb_debounced(btnL_db));
Debounce db2(.clk(clk),.reset(rst),.pb(btnC),.pb_debounced(btnC_db));
Debounce db3(.clk(clk),.reset(rst),.pb(btnR),.pb_debounced(btnR_db));
Debounce db4(.clk(clk),.reset(rst),.pb(btnD),.pb_debounced(btnD_db));
Debounce db5(.clk(clk),.reset(rst),.pb(btnU),.pb_debounced(btnU_db));

OnePulse op1(.clock(clk),.signal(btnL_db),.signal_single_pulse(insert_five));
OnePulse op2(.clock(clk),.signal(btnC_db),.signal_single_pulse(insert_ten));
OnePulse op3(.clock(clk),.signal(btnR_db),.signal_single_pulse(insert_fifty));
OnePulse op4(.clock(clk),.signal(btnD_db),.signal_single_pulse(clear));
OnePulse op5(.clock(clk),.signal(btnU_db),.signal_single_pulse(rst));


wire [8:0] cash;
Vending_Machine_FSM vendor(
    .clk(clk),
    .rst(rst),
    .clear(clear),
    .insert_five(insert_five),
    .insert_ten(insert_ten),
    .insert_fifty(insert_fifty),
    .drink_select(4'b0000), //change to key signals later
    .drink_avail(outLED),
    .cash(cash));

SevenSegmentDisplay ssd(.display(display),.digit(digit),.cash(cash),.rst(reset),.clk(clk));

endmodule

//Moore FSM
module Vending_Machine_FSM (
    input clk,
    input rst,//active high reset, be careful
    input clear,
    input insert_five,
    input insert_ten,
    input insert_fifty,
    input [3:0]drink_select,
    output [3:0]drink_avail,
    output reg [8:0]cash 
);


reg [8:0] next_cash;
parameter MAX = 9'd100;
parameter MIN = 9'd0;
parameter CHANGE_UNIT = 9'd5;
parameter WATER = 9'd20;
parameter OOLONG = 9'd25;
parameter COKE = 9'd30;
parameter COFFEE = 9'd80;

assign drink_avail[0] = (cash >= WATER);
assign drink_avail[1] = (cash >= OOLONG);
assign drink_avail[2] = (cash >= COKE);
assign drink_avail[3] = (cash >= COFFEE);


wire select;//return 1 if any drink is selected and available
assign select = |(drink_select&drink_avail); //unary reduction operator



reg [2-1:0] state, next_state;
parameter IDLE = 2'b00;//waiting for coins
parameter BUY = 2'b01;//dispensing drink
parameter CHANGE = 2'b10;//returning change

reg [26-1:0] clock_divider;// ~1Hz clock
always @(posedge clk, posedge rst) begin
    if (rst) begin
        clock_divider <= 26'b0;
    end else begin
        clock_divider <= clock_divider + 26'b1;
    end
end


//seq
always @(posedge clk) begin 
if(rst) begin
    cash <= MIN;
    state <= IDLE;
end
else begin 
    state <= next_state;
    cash <= (next_cash > MAX) ? MAX : next_cash;

   case(state)
       BUY: begin
       end
       CHANGE: begin
           if(clock_divider == {26{1'b1}}) begin
               cash <= cash - CHANGE_UNIT;
           end else cash <= cash;
       end
       default: begin //IDLE
           cash <= (next_cash > MAX) ? MAX : next_cash;
       end
   endcase 
end
end

//comb
always @(*) begin
    next_cash = cash + insert_five*5 + insert_ten*10 + insert_fifty*50;
   case(state)
       IDLE: begin
           if(clear && cash >= CHANGE_UNIT) next_state = CHANGE;
           else begin
               if ( select ) next_state = BUY;
               else next_state = IDLE;
           end 
       end
       BUY: begin
           next_state = CHANGE;
       end
       CHANGE: begin
           next_state = (cash == 0) ? IDLE : CHANGE;
       end
       default: begin
           next_state = IDLE;
       end
   endcase
end


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
//the signal must be stable for 4 cycles of 100Hz clock
// 400 Hz = 2.5 ms
module Debounce(
    input clk,
    input reset,
    input pb,
    output pb_debounced
);
    reg [20-1:0]clk_divider; //a 100Mhz/2^20 ~= 100Hz clock
    reg [4-1:0] DFF;
    assign pb_debounced = (DFF == 4'hF);

    always @(posedge clk) begin
        if (reset) begin
            clk_divider <= 1'b0;
        end else begin
            clk_divider <= clk_divider + 1'b1;
        end
    end

    always @(posedge clk) begin
        if(clk_divider == 20'hF_FFFF) begin
            DFF <= {DFF[3:0], pb};
        end else begin
            DFF <= DFF;
        end
    end

endmodule

//concurrently display stuff
module SevenSegmentDisplay(
    output reg [6:0] display,
    output reg [3:0] digit,//the rightmost 3 digits
    input wire [8:0] cash,
    input wire rst, //active high
    input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    wire [3:0] nums [2:0]; //3 digits of decimal

    //don't prepend zeros for digit 2 & 3
    assign nums[0] = cash % 10;//dangerous usage of / and % operator
    assign nums[1] = (cash < 10)? 4'b1111 : (cash / 10) % 10;
    assign nums[2] = (cash < 100)? 4'b1111 : cash / 100;

    
    //counter / clock divider
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            clk_divider <= 16'b0;
        end else begin
            clk_divider <= clk_divider + 16'b1;
        end
    end
    
    //display cycle 
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            display_num <= 4'b0000;
            digit <= 4'b1111;
        end else if (clk_divider == 16'hFFFF) begin
            case (digit)
                4'b1110 : begin
                    display_num <= nums[1];
                    digit <= 4'b1101;
                end
                4'b1101 : begin
                    display_num <= nums[2];
                    digit <= 4'b1011;
                end
                // 4'b1011 : begin
                //     display_num <= nums[15:12];
                //     digit <= 4'b0111;
                // end
                4'b1011 : begin 
                    display_num <= nums[0];
                    digit <= 4'b1110;
                end
                default : begin
                    display_num <= nums[0];
                    digit <= 4'b1110;
                end				
            endcase
        end else begin
            display_num <= display_num;
            digit <= digit;
        end
    end
    
    always @ (*) begin
        case (display_num) //decode 4-bit number to 7-segment display postion
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
            default : display = 7'b1111111;
        endcase
    end
    
endmodule

//keyboard I/O
