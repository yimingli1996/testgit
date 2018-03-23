`timescale 1ns / 1ps

module var_clocktest(
    input[31:0] period,
    input clkin, 
    output reg clkout = 0);
reg[31:0] count =  0;







