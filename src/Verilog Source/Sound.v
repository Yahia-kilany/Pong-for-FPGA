

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
    input wire clk,           // System clock
    input wire rst,           // Reset signal
    input wire paddle_hit,    // Indicates a collision with a paddle
    input wire wall_hit,      // Indicates a collision with the wall
    input wire score1,        // Signal indicating player 1 scored a point
    input wire score2,        // Signal indicating player 2 scored a point
    output wire audio_out     // PWM audio output for sound generation
);

    // Parameters for different audio frequencies
    localparam PADDLE_FREQ = 440;  // Frequency for paddle collision (A4 note, 440 Hz)
    localparam WALL_FREQ = 330;    // Frequency for wall collision (E4 note, 330 Hz)
    localparam SCORE_FREQ = 880;   // Frequency for scoring (A5 note, 880 Hz)

    // Signal indicating a point has been scored by either player
    wire score_made;
    assign score_made = score2 || score1;

    // Sound duration control counter
    reg [19:0] duration_counter;
    localparam SOUND_DURATION = 20'd250000;  // Duration of sound (5 ms at 50 MHz clock frequency)

    // Registers for generating the tone signal
    reg [15:0] tone_counter;   // Counter for tone generation
    reg [15:0] tone_limit;     // Limit for the tone frequency period
    reg audio_pwm;             // PWM signal for audio output
    reg sound_active;          // Signal indicating if sound is currently active

    // Determine the tone limit based on the event
    always @* begin
        case ({paddle_hit, wall_hit, score_made})
            3'b100: tone_limit = 50_000_000 / PADDLE_FREQ / 2;  // Frequency for paddle hit
            3'b010: tone_limit = 50_000_000 / WALL_FREQ / 2;    // Frequency for wall hit
            3'b001: tone_limit = 50_000_000 / SCORE_FREQ / 2;   // Frequency for scoring
            default: tone_limit = 0;  // No sound if no events are active
        endcase
    end

    // Control the duration of the sound
    always @(posedge clk) begin
        if (rst) begin
            duration_counter <= 0;
            sound_active <= 0;
        end
        else begin
            // If a sound event occurs, reset the duration counter and activate the sound
            if (paddle_hit || wall_hit || score_made) begin
                duration_counter <= SOUND_DURATION;
                sound_active <= 1;
            end
            // Continue the sound if the duration counter is greater than 0
            else if (duration_counter > 0) begin
                duration_counter <= duration_counter - 1;
                sound_active <= 1;
            end
            // Deactivate the sound when the duration counter reaches 0
            else begin
                sound_active <= 0;
            end
        end
    end

    // Tone generator logic
    always @(posedge clk) begin
        if (rst) begin
            tone_counter <= 0;
            audio_pwm <= 0;
        end
        else if (sound_active && tone_limit > 0) begin
            // Toggle the audio PWM signal when the tone counter reaches the tone limit
            if (tone_counter >= tone_limit) begin
                tone_counter <= 0;
                audio_pwm <= ~audio_pwm;
            end
            else begin
                tone_counter <= tone_counter + 1;
            end
        end
        else begin
            // Reset the audio output when sound is not active or tone limit is zero
            audio_pwm <= 0;
            tone_counter <= 0;
        end
    end

    // Final audio output signal, active only when sound is active
    assign audio_out = audio_pwm & sound_active;

endmodule
