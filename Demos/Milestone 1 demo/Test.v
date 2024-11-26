module vga_test
    (
        input wire clk, reset,
        input wire [11:0] sw,
        output wire hsync, vsync,
        output wire [11:0] rgb
    );

    // Register for RGB values
    reg [11:0] rgb_buffer;

    // Signal from vga_sync to enable RGB output
    wire video_active;

    // Instantiate the VGA synchronization module
    vga_sync vga_unit (
        .clk(clk), 
        .reset(reset), 
        .hsync(hsync), 
        .vsync(vsync),
        .video_on(video_active), 
        .p_tick(), 
        .x(), 
        .y()
    );

    // RGB signal logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            rgb_buffer <= 12'b0; // Clear RGB on reset
        else
            rgb_buffer <= sw; // Update RGB with input switch values
    end

    // Output RGB values when video is active, otherwise output black
    assign rgb = video_active ? rgb_buffer : 12'b0;

endmodule
