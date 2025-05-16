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
logic [31:0] A_t, B_t;
wait(rst);
repeat(100) 
begin
  @(posedge clk);
  if( !std::randomize(A_t) with {A_t inside {[0:10]};} )   // !std::randomize(A_t) calls SystemVerilog's built-in randomization function  
                                                           // A_t inside {[0:10] a constraint to keep the value between 0 and 10.
    $error("A was not randomized!");                       
  void'(std::randomize(B_t) with {B_t inside {[0:10]};});   
  A <= A_t;
  B <= B_t;
end
$stop();
end

endmodule