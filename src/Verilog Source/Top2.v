`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 04:38:25 PM
// Design Name: 
// Module Name: Top
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


module Top(
    input clk_100MHz,       // 100 MHz clock signal from the Basys 3 board
    input reset,            // Reset signal (button R)
    input up1,              // Up button for paddle 1 (button U)
    input down1,            // Down button for paddle 1 (button D)
    input up2,              // Up button for paddle 2 (button U)
    input down2,            // Down button for paddle 2 (button D)
    output hsync,           // Horizontal sync signal for VGA display
    output vsync,           // Vertical sync signal for VGA display
    output w_score1,        // Score signal for player 1
    output w_score2,        // Score signal for player 2
    output [6:0] seg,       // 7-segment display output
    output [3:0] an,        // Anode signals for the 4-digit display
    output [11:0] rgb,      // RGB color output for VGA display
    output audio             // PWM audio output for sound effects
);

    // Internal wire declarations
    wire w_reset, w_up1, w_down1, w_up2, w_down2, w_vid_on, w_p_tick;
    wire [1:0] w_state;      // State wire for game state management
    wire [9:0] w_x, w_y;     // X and Y coordinates for the current pixel on the screen
    wire [11:0] w_rgb_next;  // Next RGB color value to be displayed
    wire [3:0] w_score1_unit, w_score2_unit; // Units place of the scores
    wire pad1_on, pad2_on, ball_on, text_on; // Signals indicating the presence of objects
    wire w_score1, w_score2; // Signals indicating if a player has scored
    wire w_wall_hit, w_pad_hit; // Signals for collisions with wall and paddles
    wire [9:0] y_pad1_t, y_pad1_b, y_pad2_t, y_pad2_b; // Y-coordinate boundaries for paddles
    wire [9:0] X_PAD1_L, X_PAD1_R, X_PAD2_L, X_PAD2_R; // X-coordinate boundaries for paddles

    // Instantiate the VGA controller for video output
    vga_controller vga(
        .clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_vid_on),
        .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y)
    );

    // Instantiate the paddle logic module
    Paddle pg(
        .clk(clk_100MHz), .reset(w_reset),
        .up1(w_up1), .down1(w_down1),
        .up2(w_up2), .down2(w_down2),
        .x(w_x), .y(w_y),
        .pad1_t(y_pad1_t), .pad1_b(y_pad1_b),
        .pad1_l(X_PAD1_L), .pad1_r(X_PAD1_R),
        .pad2_t(y_pad2_t), .pad2_b(y_pad2_b),
        .pad2_l(X_PAD2_L), .pad2_r(X_PAD2_R),
        .pad1_on(pad1_on), .pad2_on(pad2_on)
    );

    // Instantiate the ball logic module
    ball b(
        .clk(clk_100MHz),
        .reset(w_reset),
        .pad1_t(y_pad1_t),
        .pad1_b(y_pad1_b),
        .pad1_r(X_PAD1_R),
        .pad1_l(X_PAD1_L),
        .pad2_t(y_pad2_t),
        .pad2_b(y_pad2_b),
        .pad2_r(X_PAD2_R),
        .pad2_l(X_PAD2_L),
        .x(w_x),
        .y(w_y),
        .ball_on(ball_on),
        .wall_hit(w_wall_hit),
        .pad_hit(w_pad_hit),
        .score1(w_score1),
        .score2(w_score2)
    );

    // Instantiate the Score_text module for displaying scores
    Score_text(
        .clk(clk_100MHz),
        .dig0(w_score1_unit), .dig1(w_score2_unit),
        .x(w_x), .y(w_y),
        .ascii_bit(text_on)
    );

    // Instantiate color multiplexer to manage object colors on the screen
    color_mux cm(
        .video_on(w_vid_on), .pad1_on(pad1_on), .pad2_on(pad2_on),
        .ball_on(ball_on), .Text_on(text_on),
        .rgb(w_rgb_next)
    );

    // Instantiate the Score module to track and update scores
    Score score_inst(
        .clk(clk_100MHz),
        .reset(w_reset),
        .score1(w_score1),
        .score2(w_score2),
        .player1_score_unit(w_score1_unit),
        .player2_score_unit(w_score2_unit)
    );

    // Instantiate the 7-segment display controller for score display
    score_7seg score_display(
        .clk(clk_100MHz),
        .reset(w_reset),
        .player1_unit(w_score1_unit),
        .player1_tens(4'b0000), // Always zero for single-digit scores
        .player2_unit(w_score2_unit),
        .player2_tens(4'b0000), // Always zero for single-digit scores
        .seg(seg),
        .an(an)
    );

    // Instantiate debouncers for button inputs to handle switch bouncing
    debouncer dbR(.clk(clk_100MHz), .btn_in(reset), .btn_out(w_reset));
    debouncer dbU1(.clk(clk_100MHz), .btn_in(up1), .btn_out(w_up1));
    debouncer dbD1(.clk(clk_100MHz), .btn_in(down1), .btn_out(w_down1));
    debouncer dbU2(.clk(clk_100MHz), .btn_in(up2), .btn_out(w_up2));
    debouncer dbD2(.clk(clk_100MHz), .btn_in(down2), .btn_out(w_down2));

    // Instantiate the sound module to generate audio signals for game events
    sound sound_inst(
        .clk(clk_100MHz),
        .rst(w_reset),
        .paddle_hit(w_pad_hit),
        .wall_hit(w_wall_hit),
        .score1(w_score1),
        .score2(w_score2),
        .audio_out(audio) // Connect the output to the Top module's audio port
    );

    // RGB buffer to store the color data before sending it to the VGA port
    reg [11:0] rgb_reg;
    always @(posedge clk_100MHz)
        if (w_p_tick)
            rgb_reg <= w_rgb_next;
    assign rgb = rgb_reg;

endmodule
