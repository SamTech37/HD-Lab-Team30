`timescale 1ns / 1ps

module Parameterized_Ping_Pong_Counter_fpga (clk, rst_n, enable, flip, max, min,
 outLED,an);
// I/O signals
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg [3-1:0] an;
output reg [7-1:0] outLED;//7-seg 


reg [7-1:0] dirLED;//7-seg display 1 & 0
reg [7-1:0] outLED1, outLED2;//7-seg display 3 & 2

wire rst_n_in, flip_in;//debounce & one-pulse for button input
wire direction;
wire [4-1:0] out;
wire clk_2_17; //clk rate divided by 2^17



//module
Parameterized_Ping_Pong_Counter ppp_counter (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .flip(flip),
    .max(max),
    .min(min),
    .direction(direction),
    .out(out)
);

//7-seg display output 
always @(posedge clk) begin
    case(out)  //need to change
    4'b0000: outLED1 <= 7'b0000001; // "0"     
    4'b0001: outLED1 <= 7'b1001111; // "1" 
    4'b0010: outLED1 <= 7'b0010010; // "2" 
    4'b0011: outLED1 <= 7'b0000110; // "3" 
    4'b0100: outLED1 <= 7'b1001100; // "4" 
    4'b0101: outLED1 <= 7'b0100100; // "5" 
    4'b0110: outLED1 <= 7'b0100000; // "6" 
    4'b0111: outLED1 <= 7'b0001111; // "7" 
    4'b1000: outLED1 <= 7'b0000000; // "8"     
    4'b1001: outLED1 <= 7'b0000100; // "9" 
    4'b1010: outLED1 <= 7'b0001000; // "A" 
    4'b1011: outLED1 <= 7'b1100000; // "b" 
    4'b1100: outLED1 <= 7'b1110010; // "c" 
    4'b1101: outLED1 <= 7'b1000010; // "d" 
    4'b1110: outLED1 <= 7'b0110000; // "E" 
    4'b1111: outLED1 <= 7'b0111000; // "F" 
    default: outLED1 <= 7'b0000001; // "0"
    endcase

    case(direction)
    1'b0:  dirLED <= 7'b1111000; //the bottom 3 segs
    1'b1: dirLED <= 7'b0001111;
    default: dirLED <= 7'b0001111; //the top 3 segs
    endcase
end

//display 4-digits concurently
reg [2-1:0]display_digit;
always @(posedge clk_2_17) begin
    case (display_digit) 
    2'b00: begin
        outLED = outLED1;
        an = 4'b0111;
        display_digit <= 2'b01;
    end
    2'b01: begin
        outLED = outLED2;
        an = 4'b1011;
        display_digit <= 2'b10;
    end

    2'b10:
    2'b11: begin
        outLED = dirLED;
        an = 4'b1100;
        display_digit <= 2'b00;
    end

    default: begin
        outLED = dirLED;
        an = 4'b1111;
        display_digit <= 2'b00; //reset display cycle
    end
    endcase

end

endmodule

/*submodule used*/

//debounce

//one-pulse

//clock divider for time-multiplexing
module Clock_Divider(clk, rst_n, clk_2_17);
input clk,rst_n;
output reg clk_2_17;

reg [17-1:0] cnt; //17-bit counter

always @(posedge clk) begin
    if(!rst_n) begin
        cnt <= 17'b0;
        clk_2_17 <= 1'b0;
    end
    else begin
        cnt <= (cnt == 17'h1ffff)? 17'b0 : cnt+1;
        clk_2_17 <= (cnt == 17'h1ffff)? 1'b1 : 1'b0;
    end
end

endmodule



//parametrized ping ping counter

