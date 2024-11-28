module car_SevenSegment(
    output reg [6:0] display,
    output reg [3:0] digit,//the rightmost 3 digits
    input wire [19:0] distance,
    input wire rst, //active high
    input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    wire [3:0] nums [2:0]; //3 digits of decimal

    //don't prepend zeros for digit 2 & 3
    assign nums[0] = distance % 10;//dangerous usage of / and % operator
    assign nums[1] = distance / 10;
    assign nums[2] = distance / 100;

    
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
                    display_num <= nums[0];
                    digit <= 4'b1101;
                end
                4'b1101 : begin
                    display_num <= nums[1];
                    digit <= 4'b1011;
                end
                4'b1011 : begin 
                    display_num <= nums[2];
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