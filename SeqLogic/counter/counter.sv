module counter  
#(
  parameter W = 8
) 
(
input        clk,
input        rst,
output logic max_tick,
output logic [W-1:0] q
);

logic [W-1:0] r_reg;
logic [W-1:0] r_next;

always_ff @(posedge clk or posedge rst) 
begin
  if(rst)
    r_reg <= '0;
  else 
    r_reg <= r_next;    
end

assign r_next   = r_reg + 1;
assign q        = r_reg;
assign max_tick = (r_reg == {W{1'b1}});

endmodule