`timescale 1ns / 1ps

module Paddle(
    input clk,  
    input reset,    
    input up1,       // control for paddle 1
    input down1,     // control for paddle 1
    input up2,       // control for paddle 2
    input down2,     // control for paddle 2
    input [9:0] x,
    input [9:0] y,
    output [9:0] pad1_t,
    output [9:0] pad1_b,
    output [9:0] pad1_l,
    output [9:0] pad1_r,
    output [9:0] pad2_t,
    output [9:0] pad2_b, 
    output [9:0] pad2_l,
    output [9:0] pad2_r,
    output wire pad1_on,  // Output signal for paddle 1 presence
    output wire pad2_on   // Output signal for paddle 2 presence
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync (vertical retrace)
    
    // PADDLE 1
    parameter X_PAD1_L = 600;
    parameter X_PAD1_R = 603;    // 4 pixels wide
    wire [9:0] y_pad1_t, y_pad1_b;
    parameter PAD_HEIGHT = 72;  // 72 pixels high
    reg [9:0] y_pad1_reg, y_pad1_next;
    parameter PAD_VELOCITY = 3;     // paddle moving velocity

    // PADDLE 2
    parameter X_PAD2_L = 36;
    parameter X_PAD2_R = 39;    // 4 pixels wide
    wire [9:0] y_pad2_t, y_pad2_b;
    reg [9:0] y_pad2_reg, y_pad2_next;

    // Register Control for Paddle 1
    always @(posedge clk or posedge reset)
        if(reset)
            y_pad1_reg <=204 ;
        else
            y_pad1_reg <= y_pad1_next;

    // Register Control for Paddle 2
    always @(posedge clk or posedge reset)
        if(reset)
            y_pad2_reg <= 204;
        else
            y_pad2_reg <= y_pad2_next;

    // Paddle 1 Control
    always @* begin
        y_pad1_next = y_pad1_reg; // no move
        if(refresh_tick) begin
            if(up1 & (y_pad1_t > PAD_VELOCITY))
                y_pad1_next = y_pad1_reg - PAD_VELOCITY;  // move up
            else if(down1 & (y_pad1_b < (Y_MAX - PAD_VELOCITY)))
                y_pad1_next = y_pad1_reg + PAD_VELOCITY;  // move down
        end
    end

    // Paddle 2 Control
    always @* begin
        y_pad2_next = y_pad2_reg; // no move
        if(refresh_tick) begin
            if(up2 & (y_pad2_t > PAD_VELOCITY))
                y_pad2_next = y_pad2_reg - PAD_VELOCITY;  // move up
            else if(down2 & (y_pad2_b < (Y_MAX - PAD_VELOCITY)))
                y_pad2_next = y_pad2_reg + PAD_VELOCITY;  // move down
        end
    end

    // Paddle Boundaries
    assign y_pad1_t = y_pad1_reg;                             // paddle 1 top position
    assign y_pad1_b = y_pad1_t + PAD_HEIGHT - 1;              // paddle 1 bottom position
    assign y_pad2_t = y_pad2_reg;                             // paddle 2 top position
    assign y_pad2_b = y_pad2_t + PAD_HEIGHT - 1;              // paddle 2 bottom position
    
    assign pad1_on = (X_PAD1_L <= x) && (x <= X_PAD1_R) &&     // pixel within paddle 1 boundaries
                     (y_pad1_t <= y) && (y <= y_pad1_b);
    assign pad2_on = (X_PAD2_L <= x) && (x <= X_PAD2_R) &&     // pixel within paddle 2 boundaries
                     (y_pad2_t <= y) && (y <= y_pad2_b);
                     
    //assigning output
    assign pad1_t = y_pad1_t;                             
    assign pad1_b = y_pad1_b;
    assign pad1_l = X_PAD1_L;
    assign pad1_r = X_PAD1_R;
    assign pad2_t = y_pad2_t;
    assign pad2_b = y_pad2_b; 
    assign pad2_l = X_PAD1_L;
    assign pad2_r = X_PAD1_R;
 endmodule
