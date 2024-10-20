`timescale 1ns / 1ps


// first make it work then refactor
module Parameterized_Ping_Pong_Counter_fpga_revision (clk, reset, enable, flip, max, min, outLED, an);
// I/O signals
input clk; // clock rate 100 MHz = 1e8 Hz, namely, 10 ns per cycle
input reset; // 1 when button pushed, 0 when not
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg [4-1:0] an;//7-seg anode
output reg [7-1:0] outLED;//7-seg digit


wire clk_2_17, clk_2_26;
wire count, direction;

//7-seg display output 
always @(posedge clk) begin case(count)  
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


//concurrent display at ~1KHz
always @(posedge clk) begin
    
end

endmodule



/*submodule used*/

//clk divider
module ClkDivider(clk, rst_n, clk_2_17, clK_2_26);

endmodule

//debounce
module Debounce(clk, pb_in, pb_debounced);
input clk, pb_in;
output pb_debounced;

reg [4-1:0] DFF; //maybe use more bits for better debounce

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



//slowed to observable rate, 1~2Hz
module Parameterized_Ping_Pong_Counter_Slowed (clk, slow_clk, rst_n, enable, flip, max, min, direction, out);
input clk
input slow_clk;
input rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg direction;
output reg [4-1:0] out;

reg next_count; //1 up, 0 down

//seq block
always @(posedge clk) begin
    if(!rst_n) begin //reset
        out <= min;
        direction <= 1'b1;
    end
    //add slow clock here
    else if(enable && max>min && out<=max && out>=min) begin
    //counter is enabled and in range
        out <= (next_count)? out+1 : out-1;
        direction <= next_count;
    end
    else begin // hold value when disabled or out-of-range 
        out <= out; 
        direction <= direction;
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