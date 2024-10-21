`timescale 1ns/1ps

module Scan_Chain_Design_T();
reg clk = 1'b0;
reg rst_n = 1'b0;
reg scan_in = 1'b0;
reg scan_en = 1'b0;
wire scan_out;


Scan_Chain_Design scan(.clk(clk), .rst_n(rst_n), .scan_in(scan_in), .scan_en(scan_en), .scan_out(scan_out));

parameter cyc = 10;
always#(cyc/2) clk = !clk;


//[TODO]
//ren = 0, wen = 1, write in
//ren = 1, wen = 0, read out
//ren = 1, wen = 1, read and write different memory
//ren = 1, wen = 1, read and write same memory


initial begin

    rst_n = 1'b0;
    scan_en = 1'b0;
    scan_in = 1'b0;

    @ (negedge clk)
    #(cyc) 
    rst_n = 1'b1;
    scan_en = 1'b1;
    //b0, b1, b2, b3
    scan_in = 1'b1;
    #(cyc) scan_in = 1'b0;
    #(cyc) scan_in = 1'b1;
    #(cyc) scan_in = 1'b0;
    //a0, a1, a2, a3
    #(cyc) scan_in = 1'b1;
    #(cyc) scan_in = 1'b0;
    #(cyc) scan_in = 1'b1;
    #(cyc) scan_in = 1'b0;
    #(cyc) scan_en = 1'b0;
    scan_in = 1'b0;
    #(cyc) scan_en = 1'b1;
    #(cyc*12);
    #(cyc) $finish;
end

endmodule
