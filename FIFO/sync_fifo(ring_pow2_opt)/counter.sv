module counter
#(
  parameter W = 24
)
(
input                 clk,
input                 rst,
input                 enable,
output logic [W-1 :0] cntr
);
always_ff @(posedge clk or posedge rst)
begin
if (rst)
  cntr <= '0;
else if (enable)
  cntr <= cntr + 1;
end
endmodule