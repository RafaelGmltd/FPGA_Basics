`timescale 1ns / 1ps

module tb_shift_reg;

    logic rst;
    logic clk;
    logic [3:0] key;

    logic [7:0] led;
    logic [3:0] cnt;
    logic en;

    shift_reg uut (
        .cnt(cnt),
        .rst(rst),
        .clk(clk),
        .key(key),
        .led(led),
        .en(en)
    );

    // Clock signal generation (50 MHz)
    always begin
        #1 clk = ~clk;  // Clock frequency 50 MHz (period 20 ns)
    end

    initial begin
  
        clk = 0;
        rst = 0;
        key = 4'b0000;
        
        rst = 1;
        #1 rst = 0;

        #1 key = 4'b0001;  // Press  button
        #64 key = 4'b0000;  // Release button
        #64 rst = 1;
 
        #10; 
        
        $stop;
    end

endmodule