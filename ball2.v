`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 05:41:53 PM
// Design Name: 
// Module Name: ball
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


module ball(
    input clk,                              // 100MHz from Basys 3
    input reset,                            // btnC
    input [9:0] pad1_t,
    input [9:0] pad1_b,
    input [9:0] pad1_r,
    input [9:0] pad1_l,
    input [9:0] pad2_t,
    input [9:0] pad2_b,
    input [9:0] pad2_r,
    input [9:0] pad2_l,
    input [9:0] x, y,                       // from VGA controller
    output ball_on,
    output score1,
    output  score2
    );
    
    parameter X_MAX = 639;                  // right border of display area
    parameter Y_MAX = 479;                  // bottom border of display area
    parameter BALL_SIZE = 10;               // width of ball diameter in pixels
    parameter BALL_VELOCITY_POS = 1;        // set position change value for positive direction
    parameter BALL_VELOCITY_NEG = -1;       // set position change value for negative direction  
    
    // Create a 60Hz refresh tick at the start of vsync 
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0;
    
    // Ball boundaries and position
    wire [9:0] ball_x_l, ball_x_r;          // Ball left and right boundary
    wire [9:0] ball_y_t, ball_y_b;          // Ball top and bottom boundary
    
    reg [9:0] ball_x_reg, ball_y_reg;       // Regs to track left, top position
    wire [9:0] ball_x_next, ball_y_next;    // Buffer wires
    
    reg [9:0] x_delta_reg, y_delta_reg;     // Track ball speed
    reg [9:0] x_delta_next, y_delta_next;   // Buffer regs  
      
    reg score1_reg, score2_reg; // Registered scores

    // Register control
    always @(posedge clk or posedge reset)
        if (reset) begin
            ball_x_reg <= 0;
            ball_y_reg <= 0;
            x_delta_reg <= 10'h001;
            y_delta_reg <= 10'h001;
        end else begin
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    // Ball boundaries
    assign ball_x_l = ball_x_reg;                   // Left boundary
    assign ball_y_t = ball_y_reg;                   // Top boundary
    assign ball_x_r = ball_x_l + BALL_SIZE - 1;     // Right boundary
    assign ball_y_b = ball_y_t + BALL_SIZE - 1;     // Bottom boundary
    
    // Ball center coordinates
    wire [9:0] ball_center_x = ball_x_l + (BALL_SIZE / 2);
    wire [9:0] ball_center_y = ball_y_t + (BALL_SIZE / 2);
    
    // Circle rendering logic
    wire [9:0] dx = (x > ball_center_x) ? (x - ball_center_x) : (ball_center_x - x);
    wire [9:0] dy = (y > ball_center_y) ? (y - ball_center_y) : (ball_center_y - y);
    
    assign ball_on = ((dx * dx) + (dy * dy)) <= ((BALL_SIZE / 2) * (BALL_SIZE / 2));

    // New ball position
    assign ball_x_next = (refresh_tick) ? ball_x_reg + x_delta_reg : ball_x_reg;
    assign ball_y_next = (refresh_tick) ? ball_y_reg + y_delta_reg : ball_y_reg;
    
    // New ball velocity 
    always @* begin
    x_delta_next = x_delta_reg; // Keep current x direction by default
    y_delta_next = y_delta_reg; // Keep current y direction by default

    if (refresh_tick) begin
        // Collision detection with the top and bottom borders
        if (ball_y_t < 1) begin
            y_delta_next = BALL_VELOCITY_POS; // Move down
        end else if (ball_y_b > Y_MAX) begin
            y_delta_next = BALL_VELOCITY_NEG; // Move up
        end
        // Collision detection with paddles
        if ((ball_x_r >= pad1_l) && (ball_x_r <= pad1_r) &&
            (ball_y_b >= pad1_t) && (ball_y_t <= pad1_b)) begin
            x_delta_next = BALL_VELOCITY_NEG; // Bounce off pad 1 (left)
        end else if ((ball_x_l <= pad2_r) && (ball_x_r >= pad2_l) &&
                    (ball_y_b >= pad2_t) && (ball_y_t <= pad2_b)) begin
            x_delta_next = BALL_VELOCITY_POS; // Bounce off pad 2 (right)
        end
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        score1_reg <= 0;
        score2_reg <= 0;
    end else if (refresh_tick) begin
        if (ball_x_l < 1) begin
            score2_reg <= 1; // Player 2 scores
        end else if (ball_x_r > X_MAX) begin
            score1_reg <= 1; // Player 1 scores
        end else begin
            score1_reg <= 0;
            score2_reg <= 0;
        end
    end
end
assign score1 = score1_reg;
assign score2 = score2_reg;


endmodule
