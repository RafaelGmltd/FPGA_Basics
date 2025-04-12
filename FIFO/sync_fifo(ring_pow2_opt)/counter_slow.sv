module counter_slow
#(
  parameter W = 24
)
(
  input  clk,
  input  rst,
  output logic [W-1:0] cntr
);
counter 
#(.W(W)) 
sub_cntr  
(
 .enable(1'b1),
 .*
);
endmodule