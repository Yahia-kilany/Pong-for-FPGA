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
    output reg [3:0] player1_score_tens, // Player 1's score tens digit
    output reg [3:0] player2_score_unit, // Player 2's score units digit
    output reg [3:0] player2_score_tens  // Player 2's score tens digit
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        player1_score_unit <= 4'b0; 
        player1_score_tens <= 4'b0;
        player2_score_unit <= 4'b0; 
        player2_score_tens <= 4'b0;
    end 
    else begin
        if (score1) begin 
            if (player1_score_unit < 9)
                player1_score_unit <= player1_score_unit + 1;
            else begin
                player1_score_unit <= 0;
                if (player1_score_tens < 9)
                    player1_score_tens <= player1_score_tens + 1;
                else
                    player1_score_tens <= 0; // Reset tens digit if it reaches 10 (if needed)
            end
        end
            
        if (score2) begin 
            if (player2_score_unit < 9)
                player2_score_unit <= player2_score_unit + 1;
            else begin
                player2_score_unit <= 0;
                if (player2_score_tens < 9)
                    player2_score_tens <= player2_score_tens + 1;
                else
                    player2_score_tens <= 0; // Reset tens digit if it reaches 10 (if needed)
            end
        end
    end
end
endmodule
