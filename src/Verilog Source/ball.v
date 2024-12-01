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
    output sq_on
    );
    
    parameter X_MAX = 639;                  // right border of display area
    parameter Y_MAX = 479;                  // bottom border of display area
    parameter SQUARE_SIZE = 10;             // width of square sides in pixels
    parameter SQUARE_VELOCITY_POS = 1;      // set position change value for positive direction
    parameter SQUARE_VELOCITY_NEG = -1;     // set position change value for negative direction  
    
    // Create a 60Hz refresh tick at the start of vsync 
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0;
    
    // Square boundaries and position
    wire [9:0] sq_x_l, sq_x_r;              // Square left and right boundary
    wire [9:0] sq_y_t, sq_y_b;              // Square top and bottom boundary
    
    reg [9:0] sq_x_reg, sq_y_reg;           // Regs to track left, top position
    wire [9:0] sq_x_next, sq_y_next;        // Buffer wires
    
    reg [9:0] x_delta_reg, y_delta_reg;     // Track square speed
    reg [9:0] x_delta_next, y_delta_next;   // Buffer regs    
    
    // Register control
    always @(posedge clk or posedge reset)
        if (reset) begin
            sq_x_reg <= 0;
            sq_y_reg <= 0;
            x_delta_reg <= 10'h001;
            y_delta_reg <= 10'h001;
        end else begin
            sq_x_reg <= sq_x_next;
            sq_y_reg <= sq_y_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    // Square boundaries
    assign sq_x_l = sq_x_reg;                   // Left boundary
    assign sq_y_t = sq_y_reg;                   // Top boundary
    assign sq_x_r = sq_x_l + SQUARE_SIZE - 1;   // Right boundary
    assign sq_y_b = sq_y_t + SQUARE_SIZE - 1;   // Bottom boundary
    
    // Ball center coordinates
    wire [9:0] ball_center_x = sq_x_l + (SQUARE_SIZE / 2);
    wire [9:0] ball_center_y = sq_y_t + (SQUARE_SIZE / 2);
    
    // Circle rendering logic
    wire [9:0] dx = (x > ball_center_x) ? (x - ball_center_x) : (ball_center_x - x);
    wire [9:0] dy = (y > ball_center_y) ? (y - ball_center_y) : (ball_center_y - y);
    
    assign sq_on = ((dx * dx) + (dy * dy)) <= ((SQUARE_SIZE / 2) * (SQUARE_SIZE / 2));

    
    // New square position
    assign sq_x_next = (refresh_tick) ? sq_x_reg + x_delta_reg : sq_x_reg;
    assign sq_y_next = (refresh_tick) ? sq_y_reg + y_delta_reg : sq_y_reg;
    
    // New square velocity 
    always @* begin
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        
        // Collision detection with the top and bottom borders
        if (sq_y_t < 1)                              // Collide with top display edge
            y_delta_next = SQUARE_VELOCITY_POS;     // Change y direction (move down)
        else if (sq_y_b > Y_MAX)                     // Collide with bottom display edge
            y_delta_next = SQUARE_VELOCITY_NEG;     // Change y direction (move up)
        
        // Collision detection with pads
        if ((sq_x_r >= pad1_l) && (sq_x_r <= pad1_r) &&
            (sq_y_b >= pad1_t) && (sq_y_t <= pad1_b)) // Check for overlap with pad1
            x_delta_next = SQUARE_VELOCITY_NEG;       // Change x direction (move left)
        else if ((sq_x_l <= pad2_r) && (sq_x_r >= pad2_l) &&
         (sq_y_b >= pad2_t) && (sq_y_t <= pad2_b)) // Check for overlap with the right pad2
    x_delta_next = SQUARE_VELOCITY_POS;  // Change x direction (move right)
    end
endmodule

