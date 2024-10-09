`timescale 1ns / 1ps


// maybe consider spliting input, main feature & output into serveral clock cycles
// clock rate of FPGA = 100 MHz = 1e8 Hz, namely, 10 ns per cycle
module Parameterized_Ping_Pong_Counter_fpga (clk, rst_n, enable, flip, max, min, outLED, an);
// I/O signals
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg [4-1:0] an;
output reg [7-1:0] outLED;//7-seg 


reg [7-1:0] dirLED;//7-seg display 1 & 0
reg [7-1:0] cntLED1, cntLED2;//7-seg display 3 & 2

wire rst_n_deb, flip_deb; //debounced
wire rst_n_in, flip_in; //debounced + onepulsed
wire direction;
wire [4-1:0] out;
wire clk_2_17, clk_2_27; //clk rate divided by 2^17 & 2^27
//about 1.3ms & 1.3s for time-multiplexing


//debounce & one-pulse for button input
Debounce deb1(clk, rst_n, rst_n_deb);
Debounce deb2(clk, flip, flip_deb);
OnePulse op1(clk,  rst_n_deb, rst_n_in);
OnePulse op2(clk,  flip_deb, flip_n_in);

//clock divider
Clock_Divider cd(clk, rst_n_in, clk_2_17, clk_2_27);


//counter module
//should count in an observable frequency
Parameterized_Ping_Pong_Counter ppp_counter (
    .clk(clk_2_27),
    .rst_n(rst_n_in),
    .enable(enable),
    .flip(flip_in),
    .max(max),
    .min(min),
    .direction(direction),
    .out(out)
);

//7-seg display output 
always @(posedge clk) begin case(out)  
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
    default: dirLED <= 7'b001_1101; 
    endcase
end

//display 4-digits concurently
reg [2-1:0]display_digit;
always @(posedge clk_2_17) begin
    case (display_digit) 
    2'b00: begin
        outLED <= cntLED1;
        an <= 4'b0111;
        display_digit <= 2'b01;
    end
    2'b01: begin
        outLED <= cntLED2;
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

endmodule

/*submodule used*/

//debounce
module Debounce(clk, pb_in, pb_debounced);
input clk, pb_in;
output pb_debounced;

reg [4-1:0] DFF;

always @(posedge clk) begin
    DFF <= {DFF[2:0], pb_in};
end
assign pb_debounced = (DFF == 4'b1111)? 1'b1 : 1'b0;
endmodule


//one-pulse
module OnePulse(clk,  pb_debounced, pb_onepulse);

input clk, pb_debounced;
output reg pb_onepulse;
reg pb_debounced_delay;

always @(posedge clk) begin
    pb_debounced_delay <= pb_debounced;
    pb_onepulse <= (pb_debounced && !pb_debounced_delay)? 1'b1 : 1'b0;
end
endmodule


//clock divider for time-multiplexing
module Clock_Divider(clk, rst_n, clk_2_17, clk_2_27);
input clk,rst_n;
output reg clk_2_17;
output reg clk_2_27;

reg [17-1:0] cnt_17; //17-bit counter
reg [27-1:0] cnt_27; //27-bit counter

always @(posedge clk) begin
    if(!rst_n) begin
        cnt_17 <= 17'b0;
        clk_2_17 <= 1'b0;
        cnt_27 <= 27'b0;
        clk_2_27 <= 1'b0;
    end
    else begin
        cnt_17 <= cnt_17+1;
        clk_2_17 <= (cnt_17 == 17'h1ffff)? 1'b1 : 1'b0;
        cnt_27 <=  cnt_27+1;
        clk_2_27 <= (cnt_27 == 27'h7fffff)? 1'b1 : 1'b0;
    end
end

endmodule


//parametrized ping ping counter

