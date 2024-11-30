`timescale 1ns / 1ps

module pixel_gen(
    input clk,  
    input reset,    
    input up1,       // control for paddle 1
    input down1,     // control for paddle 1
    input up2,       // control for paddle 2
    input down2,     // control for paddle 2
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output reg [11:0] rgb
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
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
            y_pad1_reg <= 0;
        else
            y_pad1_reg <= y_pad1_next;

    // Register Control for Paddle 2
    always @(posedge clk or posedge reset)
        if(reset)
            y_pad2_reg <= 0;
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

    // Paddle On Signals
    wire pad1_on = (X_PAD1_L <= x) && (x <= X_PAD1_R) &&     // pixel within paddle 1 boundaries
                   (y_pad1_t <= y) && (y <= y_pad1_b);
    wire pad2_on = (X_PAD2_L <= x) && (x <= X_PAD2_R) &&     // pixel within paddle 2 boundaries
                   (y_pad2_t <= y) && (y <= y_pad2_b);

    // Paddle Colors
    wire [11:0] pad1_rgb = 12'hAAA;       // gray paddle 1
    wire [11:0] pad2_rgb = 12'hF00;       // red paddle 2
    wire [11:0] bg_rgb = 12'hFFF;         // white background

    // RGB Multiplexing Circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // no value, blank
        else if(pad1_on)
            rgb = pad1_rgb;     // paddle 1 color
        else if(pad2_on)
            rgb = pad2_rgb;     // paddle 2 color
        else
            rgb = bg_rgb;       // background

endmodule

