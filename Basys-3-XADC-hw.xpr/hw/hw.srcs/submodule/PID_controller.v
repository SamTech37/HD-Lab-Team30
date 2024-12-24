
//fixed point arithmetic?

module PID_Controller (
    input wire clk,                // Clock signal
    input wire rst,                // Reset signal
    input wire signed [15:0] sp,   // Setpoint (desired value)
    input wire signed [15:0] pv,   // Process variable (measured value)
    input wire signed [15:0] kp,   // Proportional gain
    input wire signed [15:0] ki,   // Integral gain
    input wire signed [15:0] kd,   // Derivative gain
    output wire  [8-1:0] out,    // Output rotation degree (0~120)
    output wire signed [16-1:0] gain,
    output wire signed [32-1:0] temp // Temporary variable
);

    // Internal registers for calculation
    reg signed [15:0] error;       // Current error
    reg signed [15:0] prev_error;  // Previous error
    reg signed [31:0] integral;    // Accumulated integral term (32-bit to prevent overflow)
    reg signed [15:0] derivative;  // Derivative term
    reg signed [31:0] total_gain;   // Total gain
    

    localparam signed [16-1:0] MIN_GAIN = -(16'd5000);
    localparam signed [16-1:0] MAX_GAIN = 16'd5000;
    localparam signed [16-1:0] DEG_MIN = -(16'd60), DEG_MAX = 16'd60;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all values
            error <= 0;
            prev_error <= 0;
            integral <= 0;
            derivative <= 0;
            total_gain <= 0;
        end else begin
            // Calculate new error
            error <= sp - pv;

            // Calculate integral term
            integral <= integral + error;

            // Calculate derivative term
            derivative <= error - prev_error;

            // Compute PID output
            total_gain <= (kp * error) + (ki * integral[15:0]) + (kd * derivative);

            // Store current error as previous error for the next cycle
            prev_error <= error;
        end
    end
    // Output rotation degree (0~180)
    // linear interpolation
    // [MIN_GAIN, MAX_GAIN] -> [DEG_MIN, DEG_MAX]
    assign gain = total_gain[15:0];
    assign temp  = (gain-MIN_GAIN) * (DEG_MAX-DEG_MIN) / (MAX_GAIN - MIN_GAIN) + DEG_MIN;
    assign out = temp[7:0] + 8'd60; //[-60, 60] -> [0, 120]

endmodule