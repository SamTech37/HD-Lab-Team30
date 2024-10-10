`timescale 1ns / 1ps


// maybe consider spliting input, main feature & output into serveral clock cycles
module Parameterized_Ping_Pong_Counter_fpga_revision (clk, reset, enable, flip, max, min, outLED, an);
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

wire rst_n; //active-low reset for submodules
assign rst_n = !reset_in;
reg [7-1:0] dirLED;//7-seg display 1 & 0
reg [7-1:0] cntLED1, cntLED2;//7-seg display 3 & 2



//debounce & one-pulse for button input
Debounce deb1(clk, reset, reset_deb);
Debounce deb2(clk, flip, flip_deb);
OnePulse op1(clk,  reset_deb, reset_in);
OnePulse op2(clk,  flip_deb, flip_in);





//7-seg display output 
//testing display, change it back later
wire [7-1:0]seg;
seven_segment_display ssd1(clk, rst_n, seg);
always @(*) begin
    outLED = seg;
    an = max;
end

endmodule



/*submodule used*/

//7-seg display
module seven_segment_display (
    clk,        
    rst_n,      
    seg 
);

input clk, rst_n;
output reg [6:0] seg;

parameter DIV = 27;  // Clock divider value for slower clock
reg [DIV-1:0]cnt;  // Counter for dividing the clock frequency
reg slow_clk;  // Slower clock signal
always @(posedge clk) begin
    if (!rst_n) begin
        cnt <= 0;
        slow_clk <= 1'b0;
    end else begin
        cnt <= cnt + 1;
        slow_clk <= (cnt==0)? 1'b1 : 1'b0;  // Toggle slow clock
    end
end



reg [3:0] digit;  // 4-bit register for the digit to display (0-9)

always @(posedge slow_clk) begin
    if (!rst_n) begin
        digit <= 0;
    end else begin
        digit <= digit + 1;  
    end
end

// Map the digit to the 7-segment display segments (reversed bit mapping [6:0] = CA~CG)
always @(*) begin
    case (digit)
        4'd0: seg = 7'b0000001;  // Display 0 (reversed bits)
        4'd1: seg = 7'b1001111;  // Display 1 (reversed bits)
        4'd2: seg = 7'b0010010;  // Display 2 (reversed bits)
        4'd3: seg = 7'b0000110;  // Display 3 (reversed bits)
        4'd4: seg = 7'b1001100;  // Display 4 (reversed bits)
        4'd5: seg = 7'b0100100;  // Display 5 (reversed bits)
        4'd6: seg = 7'b0100000;  // Display 6 (reversed bits)
        4'd7: seg = 7'b0001111;  // Display 7 (reversed bits)
        4'd8: seg = 7'b0000000;  // Display 8 (reversed bits)
        4'd9: seg = 7'b0000100;  // Display 9 (reversed bits)
        default: seg = 7'b1111111; // Turn off display for invalid digits
    endcase
end

endmodule



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



//parametrized ping ping counter
module Parameterized_Ping_Pong_Counter_Slowed (clk, rst_n, enable, flip, max, min, direction, out);
    input clk, rst_n;
    input enable;
    input flip;
    input [4-1:0] max;
    input [4-1:0] min;
    output reg direction;
    output reg [4-1:0] out;

    reg next_count; //1 up, 0 down

    //seq block
    always @(posedge clk) begin
        if(!rst_n) begin //rst_n
            out <= min;
            direction <= 1'b1;
        end
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

