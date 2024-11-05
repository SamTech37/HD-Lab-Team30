`timescale 1ns/1ps

module Traffic_Light_Controller (clk, rst_n, lr_has_car, hw_light, lr_light);
input clk, rst_n;
input lr_has_car;
output [2:0] hw_light;
output [2:0] lr_light;
reg [2:0] hw_light, lr_light;
reg [2:0] state;
reg [2:0] next_state;
reg [6:0] count;
//to prevent the count signal show at sequentail and combinational always
reg count_reset;
parameter A = 3'b000;
parameter B = 3'b001;
parameter C = 3'b010;
parameter D = 3'b011;
parameter E = 3'b100;
parameter F = 3'b101;

//seq
always @(posedge clk) begin
    if(!rst_n) begin
        state <= A;
        count <= 1'b0;
        count_reset <= 1'b0;
    end
    else begin
        state <= next_state;
        if(count_reset) begin
            count_reset <= 1'b0;
            count <= 0;
        end
        else count <= count + 1'b1;
    end
    $display("count: %d", count);
end

//comb
always @(*) begin
    case(state)
    A: begin
        hw_light = 3'b100; //Green
        lr_light = 3'b001; //Red
        if(count >= 69 && lr_has_car == 1'b1) begin // need to test by display
            count_reset = 1'b1;
            next_state = B;
        end
        else next_state = state;
    end
    B: begin
        hw_light = 3'b010; //Yellow
        lr_light = 3'b001; //Red
        if(count >= 24) begin
            count_reset = 1'b1;
            next_state = C;
        end
        else next_state = state;
    end
    C: begin
        hw_light = 3'b001; //Red
        lr_light = 3'b001; //Red
    //not sure if the lr_has_car need to be 1??? //count >= need to count 1??
        if(count >= 0 && lr_has_car) begin
            count_reset = 1'b1;
            next_state = D;
        end
        else if(count >= 0 && !lr_has_car) begin
            count_reset = 1'b1;
            next_state = A;
        end
        else next_state = state;
    end
    D: begin
        hw_light = 3'b001; //Red
        lr_light = 3'b100; //Green
        if(count >= 69) begin
            count_reset = 1'b1;
            next_state = E;
        end
        else next_state = state;
    end
    E: begin
        hw_light = 3'b001; //Red
        lr_light = 3'b010; //Yellow
        if(count >= 24) begin
            count_reset = 1'b1;
            next_state = F;
        end
        else next_state = state;
    end
    F: begin
        hw_light = 3'b001; //Red
        lr_light = 3'b001; //Red
        if(count >= 0) begin
            count_reset = 1'b1;
            next_state = A;
        end
        else next_state = state;
    end
    default: begin
        // F
        hw_light = 3'b001; //Red
        lr_light = 3'b001; //Red
        count_reset = 1'b1;
        next_state = A;
    end
    endcase
end


endmodule
