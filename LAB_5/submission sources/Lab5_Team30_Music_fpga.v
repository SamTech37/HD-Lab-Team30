`timescale 1ns/1ps

module Music_fpga (PS2_DATA, PS2_CLK, clk, pmod_1, pmod_2, pmod_4, display, digit);
inout wire PS2_DATA;
inout wire PS2_CLK;
input wire clk;
output pmod_1;	//AIN
output pmod_2;	//GAIN
output pmod_4;	//SHUTDOWN_N
output wire [6:0] display;
output wire [3:0] digit;
parameter BEAT_FREQ = 32'd1;	//one beat=1sec //****
parameter DUTY_BEST = 10'd512;	//duty cycle=50%

reg direction;
reg fast;

wire [31:0] freq;
wire [4:0] ibeatNum;
wire beatFreq;
wire rst;
wire rst_oneplus;
wire rst_oneplus_n;

assign rst_oneplus_n = !rst_oneplus;
assign pmod_2 = 1'd1;	//no gain(6dB)
assign pmod_4 = 1'd1;	//turn-on



parameter [8:0] ENTER_CODES = 9'b0_0101_1010; // Enter => 5A
parameter [8:0] KEY_CODES_w = 9'b0_0001_1101; // w => 1D
parameter [8:0] KEY_CODES_s = 9'b0_0001_1011; // s => 1B
parameter [8:0] KEY_CODES_r = 9'b0_0010_1101; // r => 2D

wire [511:0] key_down;
wire [8:0] last_change;
wire been_ready;
    
KeyboardDecoder key_de (
    .key_down(key_down),
    .last_change(last_change),
    .key_valid(been_ready),
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(rst_oneplus),
    .clk(clk)
);

OnePulse OP1(rst_oneplus, rst, clk);
assign rst = (been_ready && key_down[ENTER_CODES]);
always @ (posedge clk, posedge rst_oneplus) begin
    if(rst_oneplus) begin
        direction <= 1'b1;
        fast <= 1'b0;
    end
    else begin
        if (been_ready && key_down[last_change] == 1'b1) begin
            case(last_change)
                // ENTER_CODES : next_direction = 1'b1;
                ENTER_CODES: begin
                    //rst <= 1'b1;
                    direction <= direction;
                    fast <= fast;
                end
                KEY_CODES_w: begin
                    //rst <= rst;
                    direction <= 1'b1;
                    fast <= fast;
                end
                KEY_CODES_s: begin
                    //rst <= rst;
                    direction <= 1'b0;
                    fast <= fast;
                end
                KEY_CODES_r: begin
                    //rst <= rst;
                    direction <= direction;
                    fast <= !fast;
                end
                default: begin
                    //rst <= rst;
                    direction <= direction;
                    fast <= fast;
                end
            endcase
        end
        else begin
            //rst <= rst;
            direction <= direction;
            fast <= fast;
        end
    end
    //if(key_down[ENTER_CODES] == 1'b0) rst <= 1'b0;
end

//Generate beat speed
PWM_gen btSpeedGen ( .clk(clk), 
					 .rst(rst_oneplus),
                     .fast(fast),
					 .freq(BEAT_FREQ),
					 .duty(DUTY_BEST), 
					 .PWM(beatFreq)
);
	
//manipulate beat
PlayerCtrl playerCtrl_00 ( .clk(beatFreq),
						   .rst(rst_oneplus),
                           .direction(direction),
						   .ibeat(ibeatNum)
);	

SevenSegment ss(.display(display), .digit(digit), .ibeatNum(ibeatNum), .rst(rst), .clk(clk));
	

//Generate variant freq. of tones
Music music00 ( .ibeatNum(ibeatNum),
				.tone(freq)
);

// Generate particular freq. signal
PWM_gen toneGen ( .clk(clk), 
				  .rst(rst_oneplus), 
				  .freq(freq),
                  .fast(1'b0),
				  .duty(DUTY_BEST), 
				  .PWM(pmod_1)
);
endmodule


//Module from Music Box
//PWM_gen
module PWM_gen (
    input wire clk,
    input wire rst,
    input fast,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);

wire [31:0] count_max = 100_000_000 / (fast? freq*2 : freq);
wire [31:0] count_duty = count_max * duty / 1024;
reg [31:0] count;
    
always @(posedge clk, posedge rst) begin
    if (rst) begin
        count <= 0;
        PWM <= 0;
    end 
    else if (count < count_max) begin
        count <= count + 1;
		if(count < count_duty)
            PWM <= 1;
        else
            PWM <= 0;
    end 
    else begin
        count <= 0;
        PWM <= 0;
    end
end

endmodule

//PlayerCtrl
module PlayerCtrl (
    input clk,
    input rst,
    input direction,
    output reg [4:0] ibeat
);
parameter BEATLEANGTH = 28;

reg reset_done;

// always @(posedge clk, posedge rst) begin
//     if (rst) begin
//         ibeat <= 0;
//         reset_done <= 0;
//     end else if (!reset_done) begin
//         reset_done <= 1;
//         ibeat <= ibeat; // Hold the value for one beatFreq cycle
//     end else begin
//         if (direction && ibeat < BEATLEANGTH) ibeat <= ibeat + 1;
//         else if (!direction && ibeat > 0) ibeat <= ibeat - 1;
//         else ibeat <= ibeat;
//     end
// end

always @(posedge clk, posedge rst) begin
    if (rst) begin
        ibeat <= 0;
        reset_done <= 0;
    end
    else begin
        if (!reset_done) begin
            reset_done <= 1;
            ibeat <= ibeat; // Hold the value for one beatFreq cycle
        end
        else begin
            if (direction && ibeat < BEATLEANGTH) ibeat <= ibeat + 1;
            else if (!direction && ibeat > 0) ibeat <= ibeat - 1;
            else ibeat <= ibeat;
        end
    end
end

endmodule


//Music
module Music (
	input [4:0] ibeatNum,	
	output reg [31:0] tone
);

parameter NM0 = 32'd262; //Do-4
parameter NM1 = 32'd294; //Re-4
parameter NM2 = 32'd330; //Mi-4
parameter NM3 = 32'd349; //Fa-4
parameter NM4 = 32'd392; //Sol-4
parameter NM5 = 32'd440; //La-4
parameter NM6 = 32'd494; //Si-4
parameter NM7 = 32'd262 << 1; //Do-5
parameter NM8 = 32'd294 << 1; //Re-5
parameter NM9 = 32'd330 << 1; //Mi-5
parameter NM10 = 32'd349 << 1; //Fa-5
parameter NM11 = 32'd392 << 1; //Sol-5
parameter NM12 = 32'd440 << 1; //La-5
parameter NM13 = 32'd494 << 1; //Si-5
parameter NM14 = 32'd262 << 2; //Do-6
parameter NM15 = 32'd294 << 2; //Re-6
parameter NM16 = 32'd330 << 2; //Mi-6
parameter NM17 = 32'd349 << 2; //Fa-6
parameter NM18 = 32'd392 << 2; //Sol-6
parameter NM19 = 32'd440 << 2; //La-6
parameter NM20 = 32'd494 << 2; //Si-6
parameter NM21 = 32'd262 << 3; //Do-7
parameter NM22 = 32'd294 << 3; //Re-7
parameter NM23 = 32'd330 << 3; //Mi-7
parameter NM24 = 32'd349 << 3; //Fa-7
parameter NM25 = 32'd392 << 3; //Sol-7
parameter NM26 = 32'd440 << 3; //La-7
parameter NM27 = 32'd494 << 3; //Si-7
parameter NM28 = 32'd262 << 4; //Do-8

always @(*) begin
	case (ibeatNum)
		5'd0 : tone = NM0;
		5'd1 : tone = NM1;
		5'd2 : tone = NM2;
		5'd3 : tone = NM3;
        5'd4 : tone = NM4;
        5'd5 : tone = NM5;
        5'd6 : tone = NM6;
        5'd7 : tone = NM7;
		5'd8 : tone = NM8;
		5'd9 : tone = NM9;
        5'd10 : tone = NM10;
        5'd11 : tone = NM11;
        5'd12 : tone = NM12;
        5'd13 : tone = NM13;
        5'd14 : tone = NM14;
        5'd15 : tone = NM15;
		5'd16 : tone = NM16;
		5'd17 : tone = NM17;
		5'd18 : tone = NM18;
        5'd19 : tone = NM19;
        5'd20 : tone = NM20;
        5'd21 : tone = NM21;
        5'd22 : tone = NM22;
		5'd23 : tone = NM23;
		5'd24 : tone = NM24;
        5'd25 : tone = NM25;
        5'd26 : tone = NM26;
        5'd27 : tone = NM27;
        5'd28 : tone = NM28;
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
//Do we need other code like Keboardctrl?? or just use IP

module SevenSegment(
    output reg [6:0] display,
    output reg [3:0] digit,
    input wire [4:0] ibeatNum,
    input wire rst,
    input wire clk
    );
    
    reg [4:0] display_num;
    always @ (posedge clk) begin
        digit <= 4'b1110;
        display_num <= ibeatNum;
    end
    
    always @ (*) begin
        case (display_num)
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
