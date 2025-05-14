`timescale 1ns / 1ps

module moore_fsm;

    // Testbench signals
logic       clk;
logic       rst;
logic       en;
logic [1:0] x;
logic [2:0] y;
 
moore_fsm uut (
.clk (clk),
.rst (rst),
.en  (en),
.x   (x),
.y   (y)

);

always #5 clk = ~clk;  

initial begin
clk = 0;
rst = 0;
en  = 0;
x   = 2'd0;

rst = 1;
#2;
rst = 0;
en  = 1; // Enable FSM
#20  

// Test case: Transition from S0-> S1-> S4-> S3-> S0
x = 2'd2; #10;  // Should go to S1
x = 2'd3; #10;  // Should go to S2
x = 2'd0; #10;  // Should go to S4
x = 2'd1; #10;  // Should go to S3
x = 2'd2; #10;  // Should go to S0
$finish;
end

endmodule