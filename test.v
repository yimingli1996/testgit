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





