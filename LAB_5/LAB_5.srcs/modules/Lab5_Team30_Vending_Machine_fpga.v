`timescale 1ns/1ps

// [TODO]


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


wire [3:0] drink_select;
wire key_A, key_S, key_D, key_F;
KeyInputDetector key_input(
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(rst),
    .clk(clk),
    .key_A(key_A),//COFFEE
    .key_S(key_S),//COKE
    .key_D(key_D),//OOLONG
    .key_F(key_F)//WATER
);

// OnePulse op6(.clock(clk),.signal(key_A),.signal_single_pulse(drink_select[3]));
// OnePulse op7(.clock(clk),.signal(key_S),.signal_single_pulse(drink_select[2]));
// OnePulse op8(.clock(clk),.signal(key_D),.signal_single_pulse(drink_select[1]));
// OnePulse op9(.clock(clk),.signal(key_F),.signal_single_pulse(drink_select[0]));
assign drink_select[3] = key_A;
assign drink_select[2] = key_S;
assign drink_select[1] = key_D;
assign drink_select[0] = key_F;



wire [8:0] cash;
// wire state;
Vending_Machine_FSM vendor(
    .clk(clk),
    .rst(rst),
    .clear(clear),
    .insert_five(insert_five),
    .insert_ten(insert_ten),
    .insert_fifty(insert_fifty),
    .drink_select(drink_select), //change to key signals later
    .drink_avail(outLED),
    .cash(cash)
    // .state(state) //for tesing
    );

SevenSegmentDisplay ssd(
    .display(display),
    .digit(digit),
    .cash(cash),
    .rst(reset),
    .clk(clk)
    //.state(state)
    );

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
    // output reg state
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


reg state;
reg next_state;
parameter IDLE = 1'b0;//waiting for coins or selection
parameter CHANGE = 1'b1;//returning change

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

    if (state == IDLE) begin
        cash <= (next_cash > MAX) ? MAX : next_cash;
    end
    else begin //CHANGE
        if(clock_divider == {26{1'b1}} && cash>=CHANGE_UNIT) begin
            cash <= cash - CHANGE_UNIT;
        end else cash <= cash;
    end
end
end

//comb
//please refactor the FSM logic for
//calculating & updating next_cash
//the current BUY logic is flawed
always @(*) begin

    if(state == IDLE) begin
        next_state = (clear || select) ? CHANGE : IDLE;
        if(drink_select[3]&&drink_avail[3]) next_cash = cash - COFFEE;
        else if(drink_select[2]&&drink_avail[2]) next_cash = cash - COKE;
        else if(drink_select[1]&&drink_avail[1]) next_cash = cash - OOLONG;
        else if(drink_select[0]&&drink_avail[0]) next_cash = cash - WATER;
        else next_cash = cash + insert_five*5 + insert_ten*10 + insert_fifty*50;
    end 
    else begin //CHANGE
        next_state = (cash == 0) ? IDLE : CHANGE;
        next_cash = (cash >= CHANGE_UNIT) ? MIN : cash - CHANGE_UNIT;//unused
    end
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
    input wire clk,
    input wire state
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
                // 4'b1011 : begin //test
                //      display_num <= state;
                //      digit <= 4'b0111;
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
//detect ASDF keys
module KeyInputDetector(
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input wire rst,
    input wire clk,
    output wire key_A,
    output wire key_S,
    output wire key_D,
    output wire key_F
    );

parameter [8:0] KEYCODE_A = 9'h0_1C;
parameter [8:0] KEYCODE_S = 9'h0_1B;
parameter [8:0] KEYCODE_D = 9'h0_23;
parameter [8:0] KEYCODE_F = 9'h0_2B;

wire [511:0] key_down;
wire [8:0] last_change;
wire been_ready;

KeyboardDecoder key_de (
    .key_down(key_down),//state of the keys
    .last_change(last_change),
    .key_valid(been_ready),
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(rst),
    .clk(clk)
);

assign key_A = been_ready && key_down[KEYCODE_A];
assign key_S = been_ready && key_down[KEYCODE_S];
assign key_D = been_ready && key_down[KEYCODE_D];
assign key_F = been_ready && key_down[KEYCODE_F];

endmodule
//Keyboard Decoder
module KeyboardDecoder(
    output reg [511:0] key_down,
    output wire [8:0] last_change,
    output reg key_valid,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input wire rst,
    input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
    parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key, next_key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state, next_state;
    reg been_ready, been_extend, been_break;
    reg next_been_ready, next_been_extend, next_been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [511:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
        .key_in(key_in),
        .is_extend(is_extend),
        .is_break(is_break),
        .valid(valid),
        .err(err),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );
    
    OnePulse op (
        .signal_single_pulse(pulse_been_ready),
        .signal(been_ready),
        .clock(clk)
    );
    
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            state <= INIT;
            been_ready  <= 1'b0;
            been_extend <= 1'b0;
            been_break  <= 1'b0;
            key <= 10'b0_0_0000_0000;
        end else begin
            state <= next_state;
            been_ready  <= next_been_ready;
            been_extend <= next_been_extend;
            been_break  <= next_been_break;
            key <= next_key;
        end
    end
    
    always @ (*) begin
        case (state)
            INIT:            next_state = (key_in == IS_INIT) ? WAIT_FOR_SIGNAL : INIT;
            WAIT_FOR_SIGNAL: next_state = (valid == 1'b0) ? WAIT_FOR_SIGNAL : GET_SIGNAL_DOWN;
            GET_SIGNAL_DOWN: next_state = WAIT_RELEASE;
            WAIT_RELEASE:    next_state = (valid == 1'b1) ? WAIT_RELEASE : WAIT_FOR_SIGNAL;
            default:         next_state = INIT;
        endcase
    end
    always @ (*) begin
        next_been_ready = been_ready;
        case (state)
            INIT:            next_been_ready = (key_in == IS_INIT) ? 1'b0 : next_been_ready;
            WAIT_FOR_SIGNAL: next_been_ready = (valid == 1'b0) ? 1'b0 : next_been_ready;
            GET_SIGNAL_DOWN: next_been_ready = 1'b1;
            WAIT_RELEASE:    next_been_ready = next_been_ready;
            default:         next_been_ready = 1'b0;
        endcase
    end
    always @ (*) begin
        next_been_extend = (is_extend) ? 1'b1 : been_extend;
        case (state)
            INIT:            next_been_extend = (key_in == IS_INIT) ? 1'b0 : next_been_extend;
            WAIT_FOR_SIGNAL: next_been_extend = next_been_extend;
            GET_SIGNAL_DOWN: next_been_extend = next_been_extend;
            WAIT_RELEASE:    next_been_extend = (valid == 1'b1) ? next_been_extend : 1'b0;
            default:         next_been_extend = 1'b0;
        endcase
    end
    always @ (*) begin
        next_been_break = (is_break) ? 1'b1 : been_break;
        case (state)
            INIT:            next_been_break = (key_in == IS_INIT) ? 1'b0 : next_been_break;
            WAIT_FOR_SIGNAL: next_been_break = next_been_break;
            GET_SIGNAL_DOWN: next_been_break = next_been_break;
            WAIT_RELEASE:    next_been_break = (valid == 1'b1) ? next_been_break : 1'b0;
            default:         next_been_break = 1'b0;
        endcase
    end
    always @ (*) begin
        next_key = key;
        case (state)
            INIT:            next_key = (key_in == IS_INIT) ? 10'b0_0_0000_0000 : next_key;
            WAIT_FOR_SIGNAL: next_key = next_key;
            GET_SIGNAL_DOWN: next_key = {been_extend, been_break, key_in};
            WAIT_RELEASE:    next_key = next_key;
            default:         next_key = 10'b0_0_0000_0000;
        endcase
    end

    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            key_valid <= 1'b0;
            key_down <= 511'b0;
        end else if (key_decode[last_change] && pulse_been_ready) begin
            key_valid <= 1'b1;
            if (key[8] == 0) begin
                key_down <= key_down | key_decode;
            end else begin
                key_down <= key_down & (~key_decode);
            end
        end else begin
            key_valid <= 1'b0;
            key_down <= key_down;
        end
    end

endmodule
