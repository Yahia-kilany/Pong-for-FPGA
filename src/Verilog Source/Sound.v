

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 10:34:27 PM
// Design Name: 
// Module Name: Sound
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


module sound(
    input wire clk,
    input wire rst,
    input wire paddle_hit,    // Collision with paddle
    input wire wall_hit,      // Collision with wall
    input wire score1,    // Point scored
    input wire score2,    // Point scored
    output wire audio_out    // PWM audio output
);

    // Parameters for different audio frequencies
    localparam PADDLE_FREQ = 440;  // 440 Hz (A4 note)
    localparam WALL_FREQ = 330;    // 330 Hz (E4 note)
    localparam SCORE_FREQ = 880;   // 880 Hz (A5 note)
    wire score_made;
    assign score_made = score2||score1; 
    // Sound duration counter
    reg [19:0] duration_counter;
    localparam SOUND_DURATION = 20'd250000;  // 5ms at 50MHz
    
    // Sound generation registers
    reg [15:0] tone_counter;
    reg [15:0] tone_limit;
    reg audio_pwm;
    reg sound_active;
    
    // Choose frequency based on event
    always @* begin
        case ({paddle_hit, wall_hit, score_made})
            3'b100: tone_limit = 50_000_000/PADDLE_FREQ/2;  // Divide by 2 for 50% duty cycle
            3'b010: tone_limit = 50_000_000/WALL_FREQ/2;
            3'b001: tone_limit = 50_000_000/SCORE_FREQ/2;
            default: tone_limit = 0;
        endcase
    end

    // Sound duration control
    always @(posedge clk) begin
        if (rst) begin
            duration_counter <= 0;
            sound_active <= 0;
        end
        else begin
            if (paddle_hit || wall_hit || score_made) begin
                duration_counter <= SOUND_DURATION;
                sound_active <= 1;
            end
            else if (duration_counter > 0) begin
                duration_counter <= duration_counter - 1;
                sound_active <= 1;
            end
            else begin
                sound_active <= 0;
            end
        end
    end

    // Tone generator
    always @(posedge clk) begin
        if (rst) begin
            tone_counter <= 0;
            audio_pwm <= 0;
        end
        else if (sound_active && tone_limit > 0) begin
            if (tone_counter >= tone_limit) begin
                tone_counter <= 0;
                audio_pwm <= ~audio_pwm;
            end
            else begin
                tone_counter <= tone_counter + 1;
            end
        end
        else begin
            audio_pwm <= 0;
            tone_counter <= 0;
        end
    end

    assign audio_out = audio_pwm & sound_active;

    
endmodule