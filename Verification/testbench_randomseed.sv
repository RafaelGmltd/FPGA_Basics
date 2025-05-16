module testbench;

logic clk;
logic rst;

logic [7:0]  A;
logic [7:0]  B;
logic [7:0]  C;
logic [31:0] seed;

adder DUT
(
.clk     (clk),
.rst     (rst),
.a       (A  ),
.b       (B  ),
.c       (C  )
);

parameter CLK_PERIOD = 10;

initial 
begin
clk <= 0;
forever 
begin
  #(CLK_PERIOD/2) clk <= ~clk;
end
end

initial begin
rst <= 1'b1;
#(CLK_PERIOD);
rst <= '0;
end
  
initial begin
seed = 32'd125; 
wait(rst);
repeat(100)
begin
  @(posedge clk);
  A <= $random(seed); 
  B <= $random(seed); 
end
$finish();
end
endmodule