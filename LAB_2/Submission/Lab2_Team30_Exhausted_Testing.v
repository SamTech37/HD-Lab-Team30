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
    //iterate through all 2^9 = 512 cases
    //takes 512 * 5 = 2560ns
    repeat (2**9) begin
        
        //check output
        //raise error if the cout or sum is incorrect
        #1 
        error = ( {cout,sum} != a+b+cin )?1:0;

        //set next input pattern   
        #4
        {a,b,cin} = {a,b,cin} + 1'b1;
    end
    //set the done signal when done
    done = 1'b1;
    
    #1 error = 1'b0; //clear the last error (if any)
    #4 done = 1'b0; //and finally, clear done signal
end

endmodule


//REMOVE these definitions bellow before submitting
//a faulty 4-bit RCA example