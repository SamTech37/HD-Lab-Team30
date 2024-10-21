`timescale 1ns / 1ps

/* Code for demo
 * reset works
 * counting up & down works
 * flip sometimes jitters
 */
//use only the system clock for always blocks
//the slowed clock should be treated as enable signals
module Parameterized_Ping_Pong_Counter_fpga (clk, reset, enable, flip, max, min, outLED, an);
// I/O signals
input clk; // clock rate 100 MHz = 1e8 Hz, namely, 10 ns per cycle
input reset; // 1 when button pushed, 0 when not
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg [4-1:0] an;
output reg [7-1:0] outLED;//7-seg 


wire reset_deb, flip_deb; //debounced
wire reset_in, flip_in; //debounced + onepulsed
wire direction;
wire [4-1:0] out;
reg [2-1:0] display_digit;
reg [7-1:0] dirLED;//7-seg display 1 & 0
reg [7-1:0] cntLED1, cntLED2;//7-seg display 3 & 2

wire rst_n; //active-low reset for submodules
wire clk_2_17,clk_2_26; // 100MHz slowed down to 1.3KHz & 2.6Hz
assign rst_n = !reset_in;//since the submodules all use active-low reset


//clock divider
Clock_Divider cd(clk, rst_n, clk_2_17,clk_2_26);

//debounce & one-pulse for button input
Debounce db1(clk, reset, reset_deb);
OnePulse op1(!clk, reset_deb, reset_in); //the signal better be up before a posedge, just like in a testbench
Debounce db2(clk, flip, flip_deb);
OnePulse op2(!clk, flip_deb, flip_in); 


//counter module
Parameterized_Ping_Pong_Counter_Slowed ppp_counter (
    .clk(clk),
    .slow_clk(clk_2_26),//should count in an observable frequency (0.5s~1s per count)
    .rst_n(rst_n),
    .enable(enable),
    .flip(flip_in),
    .max(max),
    .min(min),
    .direction(direction),
    .out(out)
);

//7-seg display output logic
always @(direction or out) begin
    case(out)  
     4'b0000:begin
         cntLED1 <= 7'b0000001; // "0"
         cntLED2 <= 7'b0000001; // "0"
     end
    4'b0001:begin
        cntLED1 <= 7'b1001111; // "1" 
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b0010:begin
        cntLED1 <= 7'b0010010; // "2" 
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b0011:begin
        cntLED1 <= 7'b0000110; // "3" 
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b0100:begin
        cntLED1 <= 7'b1001100; // "4" 
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b0101:begin
        cntLED1  <= 7'b0100100; // "5"
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b0110:begin
        cntLED1 <= 7'b0100000; // "6" 
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b0111:begin
        cntLED1 <= 7'b0001111; // "7" 
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b1000:begin
        cntLED1 <= 7'b0000000; // "8" 
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b1001:begin
        cntLED1 <= 7'b0000100; // "9"
        cntLED2 <= 7'b0000001; // "0"
    end
    4'b1010:begin
        cntLED1 <= 7'b0000001; // "0"
        cntLED2 <= 7'b1001111; // "1" 
    end
    4'b1011:begin
        cntLED1 <= 7'b1001111; // "1" 
        cntLED2 <= 7'b1001111; // "1" 
    end
    4'b1100:begin
        cntLED1 <= 7'b0010010; // "2" 
        cntLED2 <= 7'b1001111; // "1" 
    end
    4'b1101:begin
        cntLED1 <= 7'b0000110; // "3" 
        cntLED2 <= 7'b1001111; // "1" 
    end
    4'b1110:begin
        cntLED1 <= 7'b1001100; // "4" 
        cntLED2 <= 7'b1001111; // "1" 
    end
    4'b1111:begin
        cntLED1  <= 7'b0100100; // "5" 
        cntLED2 <= 7'b1001111; // "1" 
    end
    default:begin
        cntLED1 <= 7'b0000001; // "0"
        cntLED2 <= 7'b0000001; // "0"
    end
    endcase

    case(direction)
    1'b0:  dirLED <= 7'b110_0011; //the bottom 3 segs
    1'b1: dirLED <= 7'b001_1101; //the top 3 segs
    default: dirLED <= 7'b110_0011; //the bottom 3 segs
    endcase
end

//display 4-digits concurently
//an[3:0] & outLED[6:0]
always @(posedge clk) begin
    if (!rst_n) begin
        display_digit <= 2'b00;
        an <= 4'b1111;
        outLED <= 7'b111_1111;
    end
    else begin
        if(!clk_2_17) begin
            display_digit <= display_digit;
            outLED <= outLED;
            an <= an;
        end
        else begin
        case (display_digit) 
            2'b00: begin
                outLED <= cntLED2;
                an <= 4'b0111;
                display_digit <= 2'b01;
            end
            2'b01: begin
                outLED <= cntLED1;
                an <= 4'b1011;
                display_digit <= 2'b10;
            end

            2'b10, 2'b11: begin
                outLED <= dirLED;
                an <= 4'b1100;
                display_digit <= 2'b00;
            end

            default: begin
                outLED <= dirLED;
                an <= 4'b1111;
                display_digit <= 2'b00; //reset display cycle
            end
        endcase
        end
    end
end


endmodule

/*submodule used*/

//debounce
module Debounce(clk, pb_in, pb_debounced);
input clk, pb_in;
output pb_debounced;

reg [16-1:0] DFF; //the signal has to be stable for 16 cycles = 160ns

always @(posedge clk) begin
    DFF <= {DFF[14:0], pb_in};
end
assign pb_debounced = (DFF == 16'hFFFF)? 1'b1 : 1'b0;
endmodule


//one-pulse, 
//the signal will be up for exactly one clock cycle, 
//after button pushed
module OnePulse(clk,  pb_debounced, pb_onepulse);

input clk, pb_debounced;
output reg pb_onepulse;
reg pb_debounced_delay;

always @(posedge clk) begin
    pb_debounced_delay <= pb_debounced;
    pb_onepulse <= (pb_debounced && !pb_debounced_delay)? 1'b1 : 1'b0;
end
endmodule


//clock divider for 
//time-multiplexing 7-seg display & 
//slowing down the counter
module Clock_Divider(clk, rst_n, clk_2_17,clk_2_26);
input clk,rst_n;
output reg clk_2_17, clk_2_26;

reg [17-1:0] cnt_17; //17-bit counter
reg [26-1:0] cnt_26; //26-bit counter

always @(posedge clk) begin
    if(!rst_n) begin
        cnt_17 <= 17'b0;
        clk_2_17 <= 1'b0;
        cnt_26 <= 26'b0;
        clk_2_26 <= 1'b0;
    end
    else begin
        cnt_17 <= cnt_17+1;
        clk_2_17 <= (cnt_17 == 17'h1_ffff)? 1'b1 : 1'b0;
        cnt_26 <= cnt_26+1;
        clk_2_26 <= (cnt_26 == 26'h3ff_ffff)? 1'b1 : 1'b0;
    end
end

endmodule


//parametrized ping ping counter, slowed
module Parameterized_Ping_Pong_Counter_Slowed (clk, slow_clk, rst_n, enable, flip, max, min, direction, out);
input clk;
input slow_clk;
input rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg direction;
output reg [4-1:0] out;

reg next_count; //1 up, 0 down

wire valid_range, in_range;
assign valid_range = (max>min);
assign in_range = (max>=out && out>=min);


//seq block
always @(posedge clk) begin
    if(!rst_n) begin //rst_n
        out <= min;
        direction <= 1'b1;
    end
    else begin
        direction <= next_count;//rationale?
        if(slow_clk && enable && valid_range && in_range) begin
            //counter is enabled and in range
            out <= (next_count)? out+1 : out-1;
        end
        else begin // hold the count when disabled, out-of-range, or when the slow_clk is not up
            out <= out; 
        end
    end
end

//comb block
always @(*) begin
    if(out == max)
        next_count = 1'b0;
    else if(out == min)
        next_count = 1'b1;
    else if (flip)
        next_count = !direction;
    else
        next_count = direction;
end
endmodule

