`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2024 08:09:53 PM
// Design Name: 
// Module Name: score_7seg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Multiplexed 7-segment display to show scores for two players.
// 
// Dependencies: clk_div_7_seg, decoder_7seg
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module score_7seg(
    input clk,               // Input clock signal (100 MHz)
    input reset,             // Reset signal
    input [3:0] player1_unit, // Player 1's units digit (4-bit)
    input [3:0] player1_tens, // Player 1's tens digit (4-bit)
    input [3:0] player2_unit, // Player 2's units digit (4-bit)
    input [3:0] player2_tens, // Player 2's tens digit (4-bit)
    output [6:0] seg,        // 7-segment display segments
    output [3:0] an          // 7-segment display anodes
);

    // Intermediate signals
    wire clk_200hz;          // 200 Hz clock for display refresh
    reg [3:0] current_digit; // Current digit to display
    reg [1:0] digit_select;  // Active digit index for multiplexing

    // Clock divider for 200 Hz refresh rate
    clk_div_7_seg clk_div_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(clk_200hz)
    );

    // Multiplexing logic to select digits
    always @(posedge clk_200hz or posedge reset) begin
        if (reset) begin
            digit_select <= 2'b00; // Start with the first digit
        end else begin
            digit_select <= digit_select + 1; // Cycle through digits
        end
    end

    // Select current digit based on `digit_select`
    always @(*) begin
        case (digit_select)
            2'b00: current_digit = player1_unit; // Player 1, units digit
            2'b01: current_digit = player1_tens; // Player 1, tens digit
            2'b10: current_digit = player2_unit; // Player 2, units digit
            2'b11: current_digit = player2_tens; // Player 2, tens digit
            default: current_digit = 4'b0000;    // Default case
        endcase
    end

    // 7-segment decoder module
    decoder decode_inst (
        .en(digit_select),
        .num(current_digit),
        .seg(seg),
        .anode(an)  
    );

endmodule
