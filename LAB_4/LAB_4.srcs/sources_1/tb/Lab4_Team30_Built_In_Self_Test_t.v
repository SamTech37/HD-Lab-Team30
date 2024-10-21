`timescale 1ns/1ps

module Built_In_Self_Test_T();
//I/O
reg clk;
reg rst_n;
reg scan_en;
wire scan_in;
wire scan_out;


//test instance
Built_In_Self_Test bist(clk, rst_n, scan_en, scan_in, scan_out);

parameter cyc = 10;
always#(cyc/2) clk = !clk;

initial begin

    clk = 1'b0;
    rst_n = 1'b0;
    scan_en = 1'b0;

    @ (negedge clk)
    #(cyc) 
    rst_n = 1'b1;
    scan_en = 1'b1;
    //b0, b1, b2, b3
    #(cyc*8)
    scan_en = 1'b0;
    #(cyc) scan_en = 1'b1;
    #(cyc*12);
    #(cyc) $finish;
end

endmodule
