
//fixed point arithmetic?

module PID_Controller (
    input wire clk,                // Clock signal
    input wire rst,                // Reset signal
    input wire signed [15:0] sp,   // Setpoint (desired value)
    input wire signed [15:0] pv,   // Process variable (measured value)
    input wire signed [15:0] kp,   // Proportional gain
    input wire signed [15:0] ki,   // Integral gain
    input wire signed [15:0] kd,   // Derivative gain
    output reg signed [7:0] out    // Output rotation degree (0~180)
);

    // Internal registers for calculation
    reg signed [15:0] error;       // Current error
    reg signed [15:0] prev_error;  // Previous error
    reg signed [31:0] integral;    // Accumulated integral term (32-bit to prevent overflow)
    reg signed [15:0] derivative;  // Derivative term
    reg signed [31:0] total_gain;   // Total gain

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all values
            error <= 0;
            prev_error <= 0;
            integral <= 0;
            derivative <= 0;
            out <= 0;
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

            // Output rotation degree (0~180)
            // logic
        end
    end
endmodule