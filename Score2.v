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

    reg score1_d, score2_d; // Delayed scoring signals for edge detection
    wire score1_edge, score2_edge;

    // Initialize registers
    initial begin
        player1_score_unit = 0;
        player1_score_tens = 0;
        player2_score_unit = 0;
        player2_score_tens = 0;
        score1_d = 0;
        score2_d = 0;
    end

    // Update delayed score signals
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            score1_d <= 0;
            score2_d <= 0;
            player1_score_unit <= 0;
            player1_score_tens <= 0;
            player2_score_unit <= 0;
            player2_score_tens <= 0;
        end else begin
            score1_d <= score1;
            score2_d <= score2;
        end
    end

    assign score1_edge = score1 & ~score1_d; // Detect rising edge
    assign score2_edge = score2 & ~score2_d; // Detect rising edge

    // Update Player 1 score
    always @(posedge clk) begin
        if (score1_edge) begin
            if (player1_score_unit < 9)
                player1_score_unit <= player1_score_unit + 1;
            else begin
                player1_score_unit <= 0;
                if (player1_score_tens < 9)
                    player1_score_tens <= player1_score_tens + 1;
                else
                    player1_score_tens <= 0; // Handle overflow if needed
            end
        end
    end

    // Update Player 2 score
    always @(posedge clk) begin
        if (score2_edge) begin
            if (player2_score_unit < 9)
                player2_score_unit <= player2_score_unit + 1;
            else begin
                player2_score_unit <= 0;
                if (player2_score_tens < 9)
                    player2_score_tens <= player2_score_tens + 1;
                else
                    player2_score_tens <= 0; // Handle overflow if needed
            end
        end
    end

endmodule
