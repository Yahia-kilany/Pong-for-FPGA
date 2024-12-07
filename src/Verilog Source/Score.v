`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2024 07:08:40 PM
// Design Name: 
// Module Name: Score
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// A simple score tracking module for two players. Outputs units digit 
// for each player's score from 0 to 9.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Score(
    input clk,                    // Clock signal
    input reset,                  // Reset signal
    input score1,                 // Signal indicating Player 1 scored
    input score2,                 // Signal indicating Player 2 scored
    output reg [3:0] player1_score_unit, // Player 1's score units digit
    output reg [3:0] player2_score_unit  // Player 2's score units digit
);

    // Always block triggered on the rising edge of the clock or reset
    always @(posedge score2 or posedge reset) begin
        if (reset) begin
            player2_score_unit <= 4'b0;
        end 
        else begin
            player2_score_unit=player2_score_unit+1;
            end
    end
    
    always @(posedge score1 or posedge reset) begin
        if (reset) begin
            player1_score_unit <= 4'b0;
        end 
        else begin
            player1_score_unit=player1_score_unit+1;
            end
    end

endmodule

