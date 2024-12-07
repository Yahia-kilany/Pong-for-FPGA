`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 05:15:07 PM
// Design Name: 
// Module Name: color_mux
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


module color_mux(
    input video_on,
    input pad1_on,
    input pad2_on,
    input ball_on,
    input Text_on,
    output reg [11:0] rgb
    );
    wire [11:0] pad1_rgb = 12'hAAA;       // gray paddle 1
    wire [11:0] pad2_rgb = 12'hF00;       // blue paddle 2
    wire [11:0] bg_rgb = 12'hFFF;         // white background
    wire [11:0] text_rgb = 12'hF00;
    wire [11:0] ball_rgb = 12'h0F0;             // red & green = yellow for square

    always @* begin
        if (~video_on)
            rgb = 12'h000;      // no value, blank
        else if (pad1_on)
            rgb = pad1_rgb;     // paddle 1 color
        else if (pad2_on)
            rgb = pad2_rgb;     // paddle 2 color
        else if(ball_on)
            rgb = ball_rgb;     // ball color
        else if(Text_on)
            rgb = text_rgb;
        else
            rgb = bg_rgb;       // background
    end

endmodule
