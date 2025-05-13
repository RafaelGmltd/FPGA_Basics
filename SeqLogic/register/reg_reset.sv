module reg_reset
(
input               clk,
input               rst,
input        [3 :0] d,
output logic [3 :0] q
);
always_ff @(posedge clk or posedge rst) 
begin
  if (rst)
    q <= 1'b0;
  else
    q <= d;      
end
    
endmodule