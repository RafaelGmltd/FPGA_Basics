module testbench;

logic clk;
logic rst;

logic [7:0] A;
logic [7:0] B;
logic [7:0] C;

adder DUT
(
.clk     (clk),
.rst     (rst),
.a       (A  ),
.b       (B  ),
.c       (C  )
);

parameter CLK_PERIOD = 10;

initial begin
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
  
// for
initial begin
wait(!rst);
  for(int i = 1; i < 100; i = i + 1) 
  begin
    @(posedge clk);
    A <= i;
    B <= i - 1;
  end
end

initial begin
wait(!rst)
  @(posedge clk)
  @(posedge clk)
  @(posedge clk)
if( C == 1 )
$display("A + B = %0d", C);
for(int i = 2; i < 100; i = i + 1)
begin
  @(posedge clk)
  if( C == i + (i -1) )
  $display("A + B = %0d", C);
end
$finish();
end

endmodule