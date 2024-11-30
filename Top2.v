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


module Top2(
    input clk_100MHz,       // from Basys 3
    input reset,            // btnR
    input up1,              // btnU for paddle 1
    input down1,            // btnD for paddle 1
    input up2,              // btnU for paddle 2
    input down2,            // btnD for paddle 2
    output hsync,           // to VGA port
    output vsync,           // to VGA port
    output [11:0] rgb       // to DAC, to VGA port
    );
    
    wire w_reset, w_up1, w_down1, w_up2, w_down2, w_vid_on, w_p_tick;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    vga_controller vga(.clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    
    pixel_gen pg(.clk(clk_100MHz), .reset(w_reset), .up1(w_up1), .down1(w_down1),
                   .up2(w_up2), .down2(w_down2), .video_on(w_vid_on), .x(w_x), .y(w_y), .rgb(rgb_next));
    
    debouncer dbR(.clk(clk_100MHz), .btn_in(reset), .btn_out(w_reset));
    debouncer dbU1(.clk(clk_100MHz), .btn_in(up1), .btn_out(w_up1));
    debouncer dbD1(.clk(clk_100MHz), .btn_in(down1), .btn_out(w_down1));
    debouncer dbU2(.clk(clk_100MHz), .btn_in(up2), .btn_out(w_up2));
    debouncer dbD2(.clk(clk_100MHz), .btn_in(down2), .btn_out(w_down2));
    
    // rgb buffer
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule

