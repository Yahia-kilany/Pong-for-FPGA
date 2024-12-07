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
    input [9:0] x,
    input [9:0] y,                       // from VGA controller
    output ball_on,
    output score1,                // Player 1 score (4 bits for scores up to 15)
    output score2                 // Player 2 score
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
    wire [9:0] ball_x_l, ball_x_r;
    wire [9:0] ball_y_t, ball_y_b;
    reg [9:0] ball_x_reg, ball_y_reg;
    wire [9:0] ball_x_next, ball_y_next;
    reg [9:0] x_delta_reg, y_delta_reg;
    reg [9:0] x_delta_next, y_delta_next;
    reg score1_reg,score2_reg;

    // Register control
    always @(posedge clk or posedge reset)
        if (reset) begin
            ball_x_reg <= X_MAX / 2; // Reset to center
            ball_y_reg <= Y_MAX / 2;
            x_delta_reg <= BALL_VELOCITY_POS;
            y_delta_reg <= BALL_VELOCITY_NEG;

        end else begin
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    // Ball boundaries
    assign ball_x_l = ball_x_reg;
    assign ball_y_t = ball_y_reg;
    assign ball_x_r = ball_x_l + BALL_SIZE - 1;
    assign ball_y_b = ball_y_t + BALL_SIZE - 1;

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

    // New ball velocity and scoring logic
    always @* begin
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;

        // Collision with top and bottom borders
        if (ball_y_t < 1)
            y_delta_next = BALL_VELOCITY_POS; // Bounce down
        else if (ball_y_b > Y_MAX)
            y_delta_next = BALL_VELOCITY_NEG; // Bounce up

        // Collision with paddles
        if ((ball_x_r >= pad1_l) && (ball_x_r <= pad1_r) &&
            (ball_y_b >= pad1_t) && (ball_y_t <= pad1_b)) begin
            x_delta_next = BALL_VELOCITY_NEG; // Bounce left
        end else if ((ball_x_l <= pad2_r) && (ball_x_r >= pad2_l) &&
                    (ball_y_b >= pad2_t) && (ball_y_t <= pad2_b)) begin
            x_delta_next = BALL_VELOCITY_POS; // Bounce right
        end
    end
   //scoring logic
    always @(posedge clk or posedge reset) begin
    if (reset) begin
        score1_reg <= 0;
        score2_reg <= 0;
    end else if (refresh_tick) begin
        if (ball_x_l >= pad1_r && ball_x_l<=X_MAX && x_delta_reg == BALL_VELOCITY_POS) begin
            score2_reg <= 1; // Player 2 scores
        end else if (ball_x_r <= pad2_l && ~(x_delta_reg == BALL_VELOCITY_POS)) begin
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
