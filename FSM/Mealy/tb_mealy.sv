`timescale 1ns / 1ps

module mealy_fsm;

    // Testbench signals
    logic clk;
    logic rst;
    logic en;
    logic [1:0] x;
    logic [1:0] y;
 

    // Instantiate the FSM module
    mealy_fsm uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .x(x),
        .y(y),
        .y_out(y_out)
    );

    // Clock generation
    always #5 clk = ~clk;  // Clock with a period of 10 time units

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        en = 0;
        x = 2'd0;

        // Apply reset
        rst = 1;
        #2;
        rst = 0;
        en = 1; // Enable FSM
        #3  

        // Test case: Transition from S2-> S0-> S1-> S3-> S0

        x = 2'd0; #10;  // Should go to S0
        x = 2'd0; #10;  // Should go to S1
        x = 2'd0; #10;  // Should go to S3
        x = 2'd0; #10;  // Should go to S0

        // Finish the test
        $finish;
    end

endmodule
