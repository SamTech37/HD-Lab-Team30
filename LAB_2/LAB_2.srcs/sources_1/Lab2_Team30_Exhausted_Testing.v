`timescale 1ns/1ps

module Exhausted_Testing(a, b, cin, error, done);
output [4-1:0] a, b;
output cin;
output error;
output done;

// input signal to the test instance.
reg [4-1:0] a = 4'b0000;
reg [4-1:0] b = 4'b0000;
reg cin = 1'b0;

// initial value for the done and error indicator: not done, no error
reg done = 1'b0;
reg error = 1'b0;


// output from the test instance.
wire [4-1:0] sum;
wire cout;

// instantiate the test instance.
Ripple_Carry_Adder rca(
    .a (a), 
    .b (b), 
    .cin (cin),
    .cout (cout),
    .sum (sum)
);

initial begin
    // design you test pattern here.
    // Remember to set the input pattern to the test instance every 5 nanasecond
    // Check the output and set the `error` signal accordingly 1 nanosecond after new input is set.
    // Also set the done signal to 1'b1 for 5 nanoseconds after the test is finished.
    
    //iterate through all 2^9 = 512 cases
    //takes 512 * 5 = 2560ns
    repeat (2**9) begin
        
        //check output
        #1 
        error = ( {cout,sum} != a+b+cin )?1:0;
        //error = ~error; to check if timing is right
        
        //set next input pattern   
        #4
        {a,b,cin} = {a,b,cin} + 1'b1;
    end
    
    
    //setting the done signal
    done = 1'b1;
    //for 5ns only
    #5 done = 1'b0;
    
    //do not use "finish" in this testbench
end

endmodule


//REMOVE these definitions before submitting

//a 4-bit RCA
module Ripple_Carry_Adder(a, b, cin, cout , sum);
input [3:0] a, b;
input cin;
output [3:0] sum;
output cout;
wire [3:0] c;
Full_Adder fa0(a[0],b[0],cin,c[0],sum[0]);
Full_Adder fa1(a[1],b[1],c[0],c[1],sum[1]);
Full_Adder fa2(a[2],b[2],c[1],c[2],sum[2]);
Full_Adder fa3(a[3],b[3],c[2],cout,sum[3]);
endmodule


