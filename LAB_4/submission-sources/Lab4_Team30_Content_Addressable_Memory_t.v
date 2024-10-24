`timescale 1ns/1ps

module Content_Addressable_Memory_T();
//I/O
reg clk = 1'b0;
reg wen=1'b0, ren=1'b0;
reg [7:0] din=8'b0;
reg [3:0] addr=4'b0;
wire [3:0] dout;
wire hit;


//unit under test
Content_Addressable_Memory CAM(clk, wen, ren, din, addr, dout, hit);


parameter cyc = 10;
always #(cyc/2) clk = ~clk;

//test
initial begin

    @(negedge clk)
    wen = 1'b1;
    ren = 1'b0;
    addr = 4'hC;
    din = 8'd10;
    
    @(negedge clk)
    @(negedge clk)
    repeat (3) begin //write same data
     addr = addr +2'b10;
     din = 8'd30;
     #(cyc);
    end
    
    repeat (4) begin //write diff. data into CAM 
     addr = addr +1'b1;
     din = din + 8'd10;
     #(cyc);
    end
    
    //read address from CAM
    @(negedge clk)
    wen = 1'b1;
    ren = 1'b1;
    addr = 4'hC;
    din = 8'd60;
    
    @(negedge clk)
    repeat (5) begin
     din = din - 8'd10;
     #(cyc);
    end

    #(cyc) $finish;
end

endmodule
