`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 01:59:20 PM
// Design Name: 
// Module Name: RisingEdgeDetector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RisingEdgeDetector (
    input wire clk,       // Clock signal
    input wire reset,     // Reset signal
    input wire signal_in, // Input signal to detect rising edge
    output reg edge_detected // Output signal goes high for one clock cycle when a rising edge is detected
);

    reg prev_signal_in;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            edge_detected <= 0;
            prev_signal_in <= 0;
        end else begin
            if (signal_in && !prev_signal_in) begin
                edge_detected <= 1; // Rising edge detected
            end else begin
                edge_detected <= 0; // Clear output if no rising edge
            end

            prev_signal_in <= signal_in;
        end
    end

endmodule
