`timescale 1ns / 1ps

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

wire left;
wire right;
wire speed_up;
wire speed_down;
wire start;
wire dclk;
wire gclk;
wire clk_seg;

var_clock(32'h20000, clk, clk_seg);
var_clock gameclk(started?((speed==2'b0) ? 32'd50000000 : ((speed==2'b1) ? 32'd12500000 : 32'd5000000)):32'd5000000, clk, gclk);
var_clock debclk(32'd5000000, clk, dclk); //10hz debounce

my_debouncer(dclk, btnU, speed_up);
my_debouncer(dclk, btnD, speed_down);
my_debouncer(dclk, btnL, left);
my_debouncer(dclk, btnR, right);
my_debouncer(dclk, btnC, start);

reg shift = 1'b0;
reg shift_dir = 1'b0;

always @(posedge dclk or posedge reset) begin
    if(reset) begin
        started <= 1'b0;
        speed <= 1'b0;
        dir <= 2'b0;
        shift <= 1'b0;
    end else begin
        started <= (start && !started) ? 1'b1 : started;
        if(speed_up) begin
            speed <= speed == 2 ? 2 : speed + 1;
        end else if(speed_down)
            speed <= speed == 0 ? 0 : speed - 1;
        dir <= started ? (left ? 2'b1 : right ? 2'd2 : dir) : 2'b0;
        shift <= shift ? 0 : (!started) && (left || right);
        shift_dir <= left;
    end
    reset <= start && started;
    boundaries <= (16'h8000 >> sw[15:13]) | (16'b1 << sw[2:0]);
end

always @(posedge clk) begin
    lose <= started && (pos >= 15 - sw[15:13] || pos <= 0 + sw[2:0]);
end

always @(posedge gclk or posedge reset or posedge lose) begin
    if(reset) begin
        people <= STARTING_POS;
        pos <= STARTING_IDX;
    end else if(lose) begin
        people <= 16'b0;
        pos <= 8'b0;
    end else if(shift) begin
        people <= shift_dir ? (pos<14 ? people << 1 : people) : (pos>1 ? people >> 1 : people);
        pos <= shift_dir ? (pos<14 ? pos + 1 : pos) : (pos>1 ? pos - 1 : pos);
    end else if(dir) begin
        if(dir == 2'b1) begin
            people <= people << 1;
            pos <= pos + 1;
        end else if(dir == 2'd2) begin
            people <= people >> 1;
            pos <= pos - 1;
        end
    end
end

assign led = lose ? {16{dclk}} : started ? people : people | boundaries;

seg_disp debug_seg(clk_seg, lose?8'h76:lose, lose?8'h79:speed, lose?8'h83:dir, lose?8'h69:started, 1'b0, seg, an, dp);

endmodule
