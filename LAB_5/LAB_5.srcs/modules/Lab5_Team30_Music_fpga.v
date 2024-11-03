`timescale 1ns/1ps

module Music_fpga (clk, rst_n, start, a, b, done, gcd);
inout wire PS2_DATA,
inout wire PS2_CLK,
input wire rst_n,
input wire clk
output pmod_1,	//AIN
output pmod_2,	//GAIN
output pmod_4	//SHUTDOWN_N

parameter BEAT_FREQ = 32'd8;	//one beat=0.125sec
parameter DUTY_BEST = 10'd512;	//duty cycle=50%

wire [31:0] freq;
wire [3:0] ibeatNum;
wire beatFreq;

assign pmod_2 = 1'd1;	//no gain(6dB)
assign pmod_4 = 1'd1;	//turn-on

//Generate beat speed
PWM_gen btSpeedGen ( .clk(clk), 
					 .rst_n(rst_n),
					 .freq(BEAT_FREQ),
					 .duty(DUTY_BEST), 
					 .PWM(beatFreq)
);
	
//manipulate beat
PlayerCtrl playerCtrl_00 ( .clk(beatFreq),
						   .rst_n(rst_n),
						   .ibeat(ibeatNum)
);	
	
//Generate variant freq. of tones
Music music00 ( .ibeatNum(ibeatNum),
				.tone(freq)
);

// Generate particular freq. signal
PWM_gen toneGen ( .clk(clk), 
				  .rst_n(rst_n), 
				  .freq(freq),
				  .duty(DUTY_BEST), 
				  .PWM(pmod_1)
);
endmodule


//Module from Music Box
//PWM_gen
module PWM_gen (
    input wire clk,
    input wire rst_n,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);

wire [31:0] count_max = 100_000_000 / freq;
wire [31:0] count_duty = count_max * duty / 1024;
reg [31:0] count;
    
always @(posedge clk, posedge reset) begin
    if (!rst_n) begin
        count <= 0;
        PWM <= 0;
    end else if (count < count_max) begin
        count <= count + 1;
		if(count < count_duty)
            PWM <= 1;
        else
            PWM <= 0;
    end else begin
        count <= 0;
        PWM <= 0;
    end
end

endmodule

//PlayerCtrl
module PlayerCtrl (
	input clk,
	input rst_n,
    input direction;
	output reg [3:0] ibeat
);
parameter BEATLEANGTH = 14;

always @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		ibeat <= 0;
	else if (direction && ibeat < BEATLEANGTH) 
		ibeat <= ibeat + 1;
    else if (!direction && ibeat > 0) 
        ibeat <= ibeat - 1;
	else 
		ibeat <= ibeat;
end

endmodule

//Music
module Music (
	input [3:0] ibeatNum,	
	output reg [31:0] tone
);

parameter NM0 = 32'd262 //Do-m
parameter NM1 = 32'd294 //Re-m
parameter NM2 = 32'd330 //Mi-m
parameter NM3 = 32'd349 //Fa-m
parameter NM4 = 32'd392 //Sol-m
parameter NM5 = 32'd440 //La-m
parameter NM6 = 32'd494 //Si-m
parameter NM7 = 32'd262 << 1; //Do-h
parameter NM8 = 32'd294 << 1; //Re-h
parameter NM9 = 32'd330 << 1; //Mi-h
parameter NM10 = 32'd349 << 1; //Fa-h
parameter NM11 = 32'd392 << 1; //Sol-h
parameter NM12 = 32'd440 << 1; //La-h
parameter NM13 = 32'd494 << 1; //Si-h
parameter NM14 = 32'd262 << 2 //Do-hh

always @(*) begin
	case (ibeatNum)
		4'd0 : tone = NM0;
		4'd1 : tone = NM1;
		4'd2 : tone = NM2;
		4'd3 : tone = NM3;
        4'd4 : tone = NM4;
        4'd5 : tone = NM5;
        4'd6 : tone = NM6;
        4'd7 : tone = NM7;
		4'd8 : tone = NM8;
		4'd9 : tone = NM9;
        4'd10 : tone = NM10;
        4'd11 : tone = NM11;
        4'd12 : tone = NM12;
        4'd13 : tone = NM13;
        4'd14 : tone = NM14;
		default : tone = NM0;
	endcase
end

endmodule

//Module from Keyboard
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

//Oneplus
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

//Sample Display //need finish
module SampleDisplay(
    output wire [3:0] digit,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input wire rst,
    input wire clk
    );
    
    parameter [8:0] LEFT_SHIFT_CODES  = 9'b0_0001_0010;
    parameter [8:0] RIGHT_SHIFT_CODES = 9'b0_0101_1001;
    parameter [8:0] KEY_CODES_00 = 9'b0_0100_0101; // 0 => 45
    parameter [8:0] KEY_CODES_01 = 9'b0_0001_0110; // 1 => 16
    parameter [8:0] KEY_CODES_02 = 9'b0_0001_1110; // 2 => 1E
    parameter [8:0] KEY_CODES_03 = 9'b0_0010_0110; // 3 => 26
    parameter [8:0] KEY_CODES_04 = 9'b0_0010_0101; // 4 => 25
    parameter [8:0] KEY_CODES_05 = 9'b0_0010_1110; // 5 => 2E
    parameter [8:0] KEY_CODES_06 = 9'b0_0011_0110; // 6 => 36
    parameter [8:0] KEY_CODES_07 = 9'b0_0011_1101; // 7 => 3D
    parameter [8:0] KEY_CODES_08 = 9'b0_0011_1110; // 8 => 3E
    parameter [8:0] KEY_CODES_09 = 9'b0_0100_0110; // 9 => 46
        
    parameter [8:0] KEY_CODES_10 = 9'b0_0111_0000; // right_0 => 70
    parameter [8:0] KEY_CODES_11 = 9'b0_0110_1001; // right_1 => 69
    parameter [8:0] KEY_CODES_12 = 9'b0_0111_0010; // right_2 => 72
    parameter [8:0] KEY_CODES_13 = 9'b0_0111_1010; // right_3 => 7A
    parameter [8:0] KEY_CODES_14 = 9'b0_0110_1011; // right_4 => 6B
    parameter [8:0] KEY_CODES_15 = 9'b0_0111_0011; // right_5 => 73
    parameter [8:0] KEY_CODES_16 = 9'b0_0111_0100; // right_6 => 74
    parameter [8:0] KEY_CODES_17 = 9'b0_0110_1100; // right_7 => 6C
    parameter [8:0] KEY_CODES_18 = 9'b0_0111_0101; // right_8 => 75
    parameter [8:0] KEY_CODES_19 = 9'b0_0111_1101; // right_9 => 7D
    
    reg [15:0] nums, next_nums;
    reg [3:0] key_num;
    reg [9:0] last_key;
    
    wire shift_down;
    wire [511:0] key_down;
    wire [8:0] last_change;
    wire been_ready;
    
    assign shift_down = (key_down[LEFT_SHIFT_CODES] == 1'b1 || key_down[RIGHT_SHIFT_CODES] == 1'b1) ? 1'b1 : 1'b0;
    
    SevenSegment seven_seg (
        .display(display),
        .digit(digit),
        .nums(nums),
        .rst(rst),
        .clk(clk)
    );
        
    KeyboardDecoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );

    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            nums <= 16'b0;
        end else begin
            nums <= next_nums;
        end
    end
    always @ (*) begin
        next_nums = nums;
        if (been_ready && key_down[last_change] == 1'b1) begin
            if (key_num != 4'b1111) begin
                if (shift_down == 1'b1) begin
                    next_nums = {key_num, nums[15:4]};
                end else begin
                    next_nums = {nums[11:0], key_num};
                end
            end else next_nums = next_nums;
        end else next_nums = next_nums;
    end

    always @ (*) begin
        case (last_change)
            KEY_CODES_00 : key_num = 4'b0000;
            KEY_CODES_01 : key_num = 4'b0001;
            KEY_CODES_02 : key_num = 4'b0010;
            KEY_CODES_03 : key_num = 4'b0011;
            KEY_CODES_04 : key_num = 4'b0100;
            KEY_CODES_05 : key_num = 4'b0101;
            KEY_CODES_06 : key_num = 4'b0110;
            KEY_CODES_07 : key_num = 4'b0111;
            KEY_CODES_08 : key_num = 4'b1000;
            KEY_CODES_09 : key_num = 4'b1001;
            KEY_CODES_10 : key_num = 4'b0000;
            KEY_CODES_11 : key_num = 4'b0001;
            KEY_CODES_12 : key_num = 4'b0010;
            KEY_CODES_13 : key_num = 4'b0011;
            KEY_CODES_14 : key_num = 4'b0100;
            KEY_CODES_15 : key_num = 4'b0101;
            KEY_CODES_16 : key_num = 4'b0110;
            KEY_CODES_17 : key_num = 4'b0111;
            KEY_CODES_18 : key_num = 4'b1000;
            KEY_CODES_19 : key_num = 4'b1001;
            default      : key_num = 4'b1111;
        endcase
    end
    
endmodule

//Do we need other code like Keboardctrl?? or just use IP
