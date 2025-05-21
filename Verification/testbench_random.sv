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
  

initial begin
wait(!rst);
  repeat(100) 
  begin
    @(posedge clk);
    A <= $random();
    B <= $random();
    // A <= $urandom_range(10,200);
    // B <= $urandom_range(0,10  );
  end
$finish();
end

endmodule