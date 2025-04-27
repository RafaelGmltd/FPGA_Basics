module tb_pow;

localparam       W    = 3;

logic            clk;
logic            rst;
logic [W   -1:0] num;
logic [W*5 -1:0] pow_output;          

pow
#(.W(W))
dut
(.*);

parameter PERIOD = 10;
initial
begin
  clk <= '0;
  forever
  begin
    #(PERIOD/2)
    clk <= ~clk;
  end
end

initial
begin
  rst <= 1;
  #(PERIOD)
  rst <= '0;
end

initial 
begin
for(int i = 2; i < 5 ; i = i + 1)
begin
@(posedge clk)
  num <= i;
end

# 60;

$stop();
end

endmodule

