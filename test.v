`timescale 1ns / 1ps

module var_clocktest(
    input[31:0] period,
    input clkin, 
    output reg clkout = 0);
reg[31:0] count =  0;
always @(posedge clkin) begin
    count <= (count == 0) ? period - 1 : count - 1;
    clkout <= (count == 0) ? ~clkout : clkout;
end
endmodule

module my_debouncertest(input clk, input btn, output out);
reg ff1 = 1'b0, ff2 = 1'b0;
always @(posedge clk) begin
    ff1 <= btn;
    ff2 <= ff1;
end
assign out = ff1 & (~ff2);
endmodule
