module digit
#(
  parameter PERIOD      = 50000,
            W_CNT       = $clog2(PERIOD)
)           
(
input                   clk,
output logic            toggle_digit
);

logic [W_CNT-1:0]       cnt;

always_ff@(posedge clk)
  if(cnt == (PERIOD-1))
  begin
    cnt                 <= '0;
    toggle_digit        <= ~toggle_digit; 
  end
  else
    cnt                 <= cnt+1;
 
endmodule