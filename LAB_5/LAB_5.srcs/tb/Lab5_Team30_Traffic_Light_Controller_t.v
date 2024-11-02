`timescale 1ns/1ps

module Traffic_Light_Controller_T ();
reg clk = 1'b0, rst_n = 1'b1;
reg lr_has_car;
wire [2:0] hw_light;
wire [2:0] lr_light;


//instantiate the module to test
Traffic_Light_Controller TL_controller (
    .clk(clk),
    .rst_n(rst_n),
    .lr_has_car(lr_has_car),
    .hw_light(hw_light),
    .lr_light(lr_light)
);


parameter cyc = 10;
always #(cyc/2) clk = ~clk;
    

initial begin


    #(cyc) $finish;
end

endmodule
