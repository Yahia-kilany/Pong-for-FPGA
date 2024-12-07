`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2024 10:01:52 AM
// Design Name: 
// Module Name: Ex4enable
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


module decoder(
input [1:0]en, input [3:0] num, output reg [6:0] seg, output reg [3:0] anode);
always @ * begin
    case (num)
    0: seg = 7'b0000001;
    1: seg = 7'b1001111;
    2: seg = 7'b0010010;
    3: seg = 7'b0000110;
    4: seg = 7'b1001100;
    5: seg = 7'b0100100;
    6: seg = 7'b0100000;
    7: seg = 7'b0001111;
    8: seg = 7'b0000000;
    9: seg = 7'b0000100;
    default seg =7'b1111110;
    endcase 
end

always @ (en) begin
    case(en)
       0: anode = 4'b1110;
       2: anode = 4'b1011;
       default : anode = 4'b1111;
    endcase
  
end
endmodule
