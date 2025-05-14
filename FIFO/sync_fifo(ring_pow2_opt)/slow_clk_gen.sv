module slow_clk_gen
#(
  parameter W = 24
)
(
input        clk,
input        rst,
output logic slow_clk_raw
);
wire [W-1:0] cntr;
counter_slow 
#(.W(W)) 
sub_counter_slow 
(
 .*
);
assign slow_clk_raw = cntr[W-1];
endmodule
