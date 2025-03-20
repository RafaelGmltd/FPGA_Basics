module posedge_detector 
(
    input  clk,rst, d, 
    output detected
);

  logic q;

  always_ff @ (posedge clk)
    if (rst)
      q <= '0;
    else
      q <= d;

  assign detected = ~ q & d;

endmodule

module one_cycle_pulse_detector
(
    input clk, rst, d, 
    output logic detected
);

  logic [2:0] q;

  always_ff @ (posedge clk)
    if (rst)
      q <= '0;
    else
      q <= {q[1:0], d}; // Shift register behavior

  assign detected = ~q[2] & q[1] & ~q[0]; // 010


endmodule