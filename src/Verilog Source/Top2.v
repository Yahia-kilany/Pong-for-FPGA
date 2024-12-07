`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 04:38:25 PM
// Design Name: 
// Module Name: Top2
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
    input clk_100MHz,       // from Basys 3
    input reset,            // btnR
    input up1,              // btnU for paddle 1
    input down1,            // btnD for paddle 1
    input up2,              // btnU for paddle 2
    input down2,            // btnD for paddle 2
    output hsync,           // to VGA port
    output vsync,           // to VGA port
    output w_score1,
    output w_score2,
    output [6:0] seg,       // 7-segment display
    output [3:0] an,     // anode for 4 digit display
    output [11:0] rgb       // to DAC, to VGA port
);

    wire w_reset, w_up1, w_down1, w_up2, w_down2, w_vid_on, w_p_tick;
    wire [9:0] w_x, w_y;
    wire [11:0] w_rgb_next;
    wire [3:0] w_score1_unit,w_score2_unit;
    wire pad1_on, pad2_on, ball_on, w_score1, w_score2;
    wire [9:0] y_pad1_t, y_pad1_b, y_pad2_t, y_pad2_b; // Add paddle boundaries
    wire [9:0] X_PAD1_L, X_PAD1_R, X_PAD2_L, X_PAD2_R; // Add paddle X boundaries

    // Instantiate the VGA controller
    vga_controller vga(
        .clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_vid_on),
        .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y)
    );

    // Instantiate the paddle logic
    Paddle pg(
        .clk(clk_100MHz), .reset(w_reset), .up1(w_up1), .down1(w_down1),
        .up2(w_up2), .down2(w_down2), .x(w_x), .y(w_y),
        .pad1_t(y_pad1_t), .pad1_b(y_pad1_b),
        .pad1_l(X_PAD1_L), .pad1_r(X_PAD1_R),
        .pad2_t(y_pad2_t), .pad2_b(y_pad2_b),
        .pad2_l(X_PAD2_L), .pad2_r(X_PAD2_R),
        .pad1_on(pad1_on), .pad2_on(pad2_on)
    );

    // Instantiate the ball logic
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
        .score1(w_score1),
        .score2(w_score2)
    );

    // Instantiate color multiplexer
    color_mux cm(
        .video_on(w_vid_on), .pad1_on(pad1_on), .pad2_on(pad2_on), .ball_on(ball_on),
        .rgb(w_rgb_next)
    );
    
    Score score_inst(
        .clk(clk_100MHz),
        .reset(w_reset),
        .score1(w_score1),
        .score2(w_score2),
        .player1_score_unit(w_score1_unit),
        .player2_score_unit(w_score2_unit)
    );

    // Instantiate the 7-segment display controller
    score_7seg score_display(
        .clk(clk_100MHz),
        .reset(w_reset),
        .player1_unit (w_score1_unit),
        .player1_tens (4'b0000),
        .player2_unit (w_score2_unit),
        .player2_tens (4'b0000),
        .seg(seg),
        .an(an)
    );
    // Debounce buttons
    debouncer dbR(.clk(clk_100MHz), .btn_in(reset), .btn_out(w_reset));
    debouncer dbU1(.clk(clk_100MHz), .btn_in(up1), .btn_out(w_up1));
    debouncer dbD1(.clk(clk_100MHz), .btn_in(down1), .btn_out(w_down1));
    debouncer dbU2(.clk(clk_100MHz), .btn_in(up2), .btn_out(w_up2));
    debouncer dbD2(.clk(clk_100MHz), .btn_in(down2), .btn_out(w_down2));

    // RGB buffer
    reg [11:0] rgb_reg;
    always @(posedge clk_100MHz)
        if (w_p_tick)
            rgb_reg <= w_rgb_next;
    assign rgb = rgb_reg;


    
endmodule


