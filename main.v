`timescale 1ns / 1ps

module var_clock(
    input[31:0] period,
    input clkin, 
    output reg clkout = 0);
reg[31:0] count =  0;
always @(posedge clkin) begin
    count <= (count == 0) ? period - 1 : count - 1;
    clkout <= (count == 0) ? ~clkout : clkout;
end
endmodule

module my_debouncer(input clk, input btn, output out);
reg ff1 = 1'b0, ff2 = 1'b0;
always @(posedge clk) begin
    ff1 <= btn;
    ff2 <= ff1;
end
assign out = ff1 & (~ff2);
endmodule
module cliff_game(input clk, input[15:0] sw, input btnC, input btnU, input btnL, input btnR, input btnD, 
                  output[15:0] led, output[6:0] seg, output[3:0] an, output dp);
parameter STARTING_POS = 16'b0000_0001_1100_0000;
parameter STARTING_IDX = 8'd7;

reg[15:0] people = STARTING_POS;
reg[1:0] speed = 2'b0;
reg[1:0] dir = 2'b0;
reg[7:0] pos = STARTING_IDX;
reg started = 1'b0;
reg reset = 1'b0;
reg lose = 1'b0;
reg[15:0] boundaries = 16'b0;



