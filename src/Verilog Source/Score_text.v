`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 05:30:21 PM
// Design Name: 
// Module Name: Score_text
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


module Score_text(
    input clk,                    // Clock signal
    input [3:0] dig0, dig1,      // Digits for player scores
    input [9:0] x, y,            // Pixel coordinates on the screen
    output ascii_bit             // Output for the ASCII bit of the character to display
    );
    
    wire [10:0] rom_addr;        // Address for the ASCII ROM
    reg [6:0] char_addr, char_addr_s;  // Character address and a temporary character address
    reg [3:0] row_addr;          // Row address for the character in the ROM
    wire [3:0] row_addr_s;       // Row address for character generation
    reg [2:0] bit_addr;          // Bit address for the character data in the ROM
    wire [2:0] bit_addr_s;       // Bit address for character generation
    wire [7:0] ascii_word;       // Data output from the ASCII ROM
    wire ascii_bit, score_on;    // Signal to indicate if a score should be displayed and ASCII bit for the character
    
    // Instantiate the ASCII ROM module to look up character data
    ascii_rom ascii_unit(.clk(clk), .addr(rom_addr), .data(ascii_word));

    // Condition to display the score: when y is in the range 32 to 63 and x is in the range 256 to 383
    assign score_on = (y >= 32) && (y < 64) && (x >= 256) && (x < 384);

    // Assign the row address based on the y-coordinate
    assign row_addr_s = y[4:1];
    // Assign the bit address based on the x-coordinate
    assign bit_addr_s = x[3:1];

    // Always block for setting character address based on x-coordinate (used to position the score)
    always @* begin
        char_addr_s = 7'h00; // Default character address is 0 (no display)
        case ((x - 256) >> 4) // Adjusts for the centered start of the score display
            4'h0 : char_addr_s = 7'h00;     // Padding for the left side
            4'h1 : char_addr_s = 7'h00;     // Padding for the left side
            4'h2 : char_addr_s = {3'b011, dig1};    // Display Player 1's score (digit 1)
            4'h3 : char_addr_s = 7'h2d;     // Display the '-' character (separator)
            4'h4 : char_addr_s = {3'b011, dig0};    // Display Player 2's score (digit 0)
            4'h6 : char_addr_s = 7'h00;     // Padding for the right side
            4'h7 : char_addr_s = 7'h00;     // Padding for the right side
            4'h8 : char_addr_s = 7'h00;     // Padding for the right side
            default: char_addr_s = 7'h00;   // Default case (no display)
        endcase
    end

    // Always block for setting final character address, row, and bit based on score display condition
    always @* begin
        if(score_on) begin
            char_addr = char_addr_s;
            row_addr = row_addr_s;
            bit_addr = bit_addr_s;
        end        
    end

    // Generate ROM address using the character address and row address
    assign rom_addr = {char_addr, row_addr};
    // Output the specific bit from the ASCII word based on the bit address
    assign ascii_bit = ascii_word[~bit_addr];
    
endmodule