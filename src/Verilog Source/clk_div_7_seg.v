`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2024 07:27:09 PM
// Design Name: 
// Module Name: clk_div_7_seg
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


module clk_div_7_seg(
    input clk_in,          // 100 MHz input clock
    input reset,           // Reset signal
    output reg clk_out     // 200 Hz output clock
);

    reg [18:0] counter;    // 19-bit counter to count up to 500,000 (2^19 > 500,000)

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 19'b0;  // Reset the counter
            clk_out <= 0;      // Reset the output clock
        end else begin
            if (counter == 19'd249_999) begin
                counter <= 19'b0;    // Reset the counter after reaching the division factor
                clk_out <= ~clk_out; // Toggle the output clock
            end else begin
                counter <= counter + 1; // Increment the counter
            end
        end
    end

endmodule

