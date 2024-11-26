module vga_sync
    (
        input wire clk, reset,
        output wire hsync, vsync, video_on, p_tick,
        output wire [9:0] x, y
    );

    // VGA synchronization parameters
    localparam H_DISPLAY       = 640;  // Horizontal display area
    localparam H_LEFT_BORDER   =  48;  // Horizontal left border
    localparam H_RIGHT_BORDER  =  16;  // Horizontal right border
    localparam H_RETRACE       =  96;  // Horizontal retrace time
    localparam H_TOTAL         = H_DISPLAY + H_LEFT_BORDER + H_RIGHT_BORDER + H_RETRACE - 1;
    localparam H_RETRACE_START = H_DISPLAY + H_RIGHT_BORDER;
    localparam H_RETRACE_END   = H_DISPLAY + H_RIGHT_BORDER + H_RETRACE - 1;

    localparam V_DISPLAY       = 480;  // Vertical display area
    localparam V_TOP_BORDER    =  10;  // Vertical top border
    localparam V_BOTTOM_BORDER =  33;  // Vertical bottom border
    localparam V_RETRACE       =   2;  // Vertical retrace time
    localparam V_TOTAL         = V_DISPLAY + V_TOP_BORDER + V_BOTTOM_BORDER + V_RETRACE - 1;
    localparam V_RETRACE_START = V_DISPLAY + V_BOTTOM_BORDER;
    localparam V_RETRACE_END   = V_DISPLAY + V_BOTTOM_BORDER + V_RETRACE - 1;

    // Pixel clock generation (mod-4 counter for 25 MHz tick)
    reg [1:0] pixel_counter;
    wire [1:0] next_pixel_counter;
    wire pixel_clock_tick;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pixel_counter <= 2'b00;
        else
            pixel_counter <= next_pixel_counter;
    end

    assign next_pixel_counter = pixel_counter + 1;
    assign pixel_clock_tick = (pixel_counter == 2'b00);

    // Horizontal and vertical counters
    reg [9:0] h_counter_reg, h_counter_next;
    reg [9:0] v_counter_reg, v_counter_next;

    // Synchronization signal registers
    reg hsync_reg, vsync_reg;
    wire hsync_next, vsync_next;

    // Update counters and sync signals
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_counter_reg <= 10'b0;
            v_counter_reg <= 10'b0;
            hsync_reg <= 1'b0;
            vsync_reg <= 1'b0;
        end else begin
            h_counter_reg <= h_counter_next;
            v_counter_reg <= v_counter_next;
            hsync_reg <= hsync_next;
            vsync_reg <= vsync_next;
        end
    end

    // Horizontal and vertical counter logic
    always @* begin
        h_counter_next = (pixel_clock_tick) ? 
                         ((h_counter_reg == H_TOTAL) ? 10'b0 : h_counter_reg + 1) 
                         : h_counter_reg;

        v_counter_next = (pixel_clock_tick && h_counter_reg == H_TOTAL) ? 
                         ((v_counter_reg == V_TOTAL) ? 10'b0 : v_counter_reg + 1) 
                         : v_counter_reg;
    end

    // Generate hsync and vsync signals (active low)
    assign hsync_next = (h_counter_reg >= H_RETRACE_START) && (h_counter_reg <= H_RETRACE_END);
    assign vsync_next = (v_counter_reg >= V_RETRACE_START) && (v_counter_reg <= V_RETRACE_END);

    // Determine if the pixel is within the display area
    assign video_on = (h_counter_reg < H_DISPLAY) && (v_counter_reg < V_DISPLAY);

    // Output assignments
    assign hsync  = ~hsync_reg;  // Active low
    assign vsync  = ~vsync_reg;  // Active low
    assign x      = h_counter_reg;
    assign y      = v_counter_reg;
    assign p_tick = pixel_clock_tick;

endmodule
