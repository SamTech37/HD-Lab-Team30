`timescale 1ns/1ps

// revised version
module Built_In_Self_Test_fpga (clk, reset, d_clk, scan_en, LFSR_reset_value, ScanDFF, outLED_7segments, an);
// I/O signals
input clk; // clock rate 100 MHz = 1e8 Hz, namely, 10 ns per cycle
input reset; // 1 when button pushed, 0 when not
input d_clk; // the clk for LFSR and Scan DFF are triggered by the right button
input scan_en; // control by a switch
input [8-1:0] LFSR_reset_value;
output reg [8-1:0] ScanDFF;
output reg [4-1:0] an;
output reg [7-1:0] outLED_7segments;//7-seg 

wire reset_deb, d_clk_deb; //debounced
wire reset_in, d_clk_in; //debounced + onepulsed

wire [4-1:0] a, b;
wire scan_in, scan_out;

reg [2-1:0] display_digit;//decide which digit to display
reg [7-1:0] scan_in_LED, aLED, bLED, scan_out_LED;//7-seg display for each digit
wire clk_2_17,clk_2_26; // 100MHz slowed down to 1.3KHz & 2.6Hz
wire rst_n; //active-low reset for submodules

assign rst_n = !reset_in;//since the submodules all use active-low reset

//clock divider
Clock_Divider cd(clk, rst_n, clk_2_17,clk_2_26);

//debounce & one-pulse for button input
Debounce db1(clk, reset, reset_deb);
OnePulse op1(!clk, reset_deb, reset_in); //the signal better be up before a posedge, just like in a testbench
Debounce db2(clk, dclk, dclk_deb);
OnePulse op2(!clk, dclk_deb, dclk_in); 


//BIST module
Built_In_Self_Test_for_fpga_in_out(
    .clk(clk), 
    .clk_d(d_clk_in), 
    .rst_n(rst_n), 
    .scan_en(scan_en), 
    .initial_state(LFSR_reset_value), 
    .scan_in(scan_in), 
    .scan_out(scan_out),
    .a(a),
    .b(b)
);

//7-seg display output logic
always @(scan_in, scan_out, a, b) begin
    ScanDFF[7:4] <= a;
    ScanDFF[3:0] <= b;
    case(a)  
    4'b0000: aLED <= 7'b0000001; // "0"
    4'b0001: aLED <= 7'b1001111; // "1" 
    4'b0010: aLED <= 7'b0010010; // "2" 
    4'b0011: aLED <= 7'b0000110; // "3" 
    4'b0100: aLED <= 7'b1001100; // "4" 
    4'b0101: aLED <= 7'b0100100; // "5"
    4'b0110: aLED <= 7'b0100000; // "6" 
    4'b0111: aLED <= 7'b0001111; // "7" 
    4'b1000: aLED <= 7'b0000000; // "8" 
    4'b1001: aLED <= 7'b0000100; // "9"
    4'b1010: aLED <= 7'b0001000; // "A"
    4'b1011: aLED <= 7'b1100000; // "b" 
    4'b1100: aLED <= 7'b0110001; // "C" 
    4'b1101: aLED <= 7'b1000010; // "d" 
    4'b1110: aLED <= 7'b0110000; // "E" 
    4'b1111: aLED <= 7'b0111000; // "F" 
    default: aLED <= 7'b0000001; // "0"
    endcase

    case(b)  
    4'b0000: bLED <= 7'b0000001; // "0"
    4'b0001: bLED <= 7'b1001111; // "1" 
    4'b0010: bLED <= 7'b0010010; // "2" 
    4'b0011: bLED <= 7'b0000110; // "3" 
    4'b0100: bLED <= 7'b1001100; // "4" 
    4'b0101: bLED <= 7'b0100100; // "5"
    4'b0110: bLED <= 7'b0100000; // "6" 
    4'b0111: bLED <= 7'b0001111; // "7" 
    4'b1000: bLED <= 7'b0000000; // "8" 
    4'b1001: bLED <= 7'b0000100; // "9"
    4'b1010: bLED <= 7'b0001000; // "A"
    4'b1011: bLED <= 7'b1100000; // "b" 
    4'b1100: bLED <= 7'b0110001; // "C" 
    4'b1101: bLED <= 7'b1000010; // "d" 
    4'b1110: bLED <= 7'b0110000; // "E" 
    4'b1111: bLED <= 7'b0111000; // "F" 
    default: bLED <= 7'b0000001; // "0"
    endcase

    case(scan_in)
    1'b0: scan_in_LED <= 7'b0000001; //0
    1'b1: scan_in_LED <= 7'b1001111; //1
    default: scan_in_LED <= 7'b0000001; //0
    endcase

    case(scan_out)
    1'b0: scan_out_LED <= 7'b0000001; //0
    1'b1: scan_out_LED <= 7'b1001111; //1
    default: scan_out_LED <= 7'b0000001; //0
    endcase
end

//display 4-digits concurently
//an[3:0] & outLED[6:0]
always @(posedge clk) begin
    if (!rst_n) begin
        display_digit <= 2'b00;
        an <= 4'b1111;
        outLED_7segments <= 7'b111_1111;
    end
    else begin
        if(!clk_2_17) begin
            display_digit <= display_digit;
            outLED_7segments <= outLED_7segments;
            an <= an;
        end
        else begin
        case (display_digit) 
            2'b00: begin
                outLED_7segments <= scan_in_LED;
                an <= 4'b0111;
                display_digit <= 2'b01;
            end
            2'b01: begin
                outLED_7segments <= aLED;
                an <= 4'b1011;
                display_digit <= 2'b10;
            end

            2'b10: begin
                outLED_7segments <= bLED;
                an <= 4'b1101;
                display_digit <= 2'b11;
            end
             2'b11: begin
                outLED_7segments <= scan_out_LED;
                an <= 4'b1110;
                display_digit <= 2'b00;
            end

            default: begin
                outLED_7segments <= scan_out_LED;
                an <= 4'b1110;
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

`timescale 1ns/1ps

module Built_In_Self_Test_for_fpga_in_out(clk, clk_d, rst_n, scan_en, initial_state, scan_in, scan_out, a, b);
input clk;
input clk_d;
input rst_n;
input scan_en;
input [8-1:0] initial_state;
output scan_in;
output scan_out;
output [3:0] a, b;
wire temp;
assign scan_in = temp;
Many_To_One_LFSRR MTO_LFSR(clk, rst_n, initial_state, clk_d, temp);
Scan_Chain_Design SCD(clk, clk_d, rst_n, temp, scan_en, scan_out, a, b);
endmodule


//Change LFSR to FPGA
module Many_To_One_LFSRR(clk, rst_n, initial_state, clk_d, fout);
input clk;
input rst_n;
input [8-1:0] initial_state;
input clk_d;
output fout;
reg [8-1:0] out;
assign fout = out[7];

//seq
always @(posedge clk) begin
//$display("fout: %d", fout);
    if(!rst_n) out <= initial_state; //reset value
    else begin
        if(clk_d)begin
            out[0] <= (out[1]^out[2])^(out[3]^out[7]);
            out[7:1] <= out[6:0];
        end
        else out <= out;
    end
end
endmodule


module Scan_Chain_Design(clk, clk_d, rst_n, scan_in, scan_en, scan_out, a, b);
input clk, clk_d, scan_in, rst_n, scan_en;
output scan_out;
output [3:0] a, b;
wire [7:0] p;
assign p = a*b;
SDFF SDFF7(clk, clk_d, rst_n, scan_in, scan_en, p[7], a[3]);
SDFF SDFF6(clk, clk_d, rst_n, a[3], scan_en, p[6], a[2]);
SDFF SDFF5(clk, clk_d, rst_n, a[2], scan_en, p[5], a[1]);
SDFF SDFF4(clk, clk_d, rst_n, a[1], scan_en, p[4], a[0]);
SDFF SDFF3(clk, clk_d, rst_n, a[0], scan_en, p[3], b[3]);
SDFF SDFF2(clk, clk_d, rst_n, b[3], scan_en, p[2], b[2]);
SDFF SDFF1(clk, clk_d, rst_n, b[2], scan_en, p[1], b[1]);
SDFF SDFF0(clk, clk_d, rst_n, b[1], scan_en, p[0], b[0]);
and(scan_out, 1, b[0]);
endmodule

module SDFF(clk, clk_d, rst_n, scan_in, scan_en, data ,din);
input clk, rst_n, scan_en, data, scan_in, clk_d;
output reg din;
reg dinnext;
always @(*) begin
    if(scan_en) dinnext = scan_in;
    else dinnext = data;
end

always @ (posedge clk) begin
    if(!rst_n) din <= 1'b0;
    else begin
        if(clk_d) din <= dinnext;
        else din <= din;
    end
end
endmodule



