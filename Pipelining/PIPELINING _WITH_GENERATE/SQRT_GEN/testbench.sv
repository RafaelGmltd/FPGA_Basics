module testbench;

localparam      WIDTH             = 8;
logic                             clk;
logic                             rst;
logic [ WIDTH      -1:0]          x;
logic [(WIDTH >> 1)-1:0]          y;



top_sqrt_pipeline
#(.WIDTH(WIDTH))
dut
(   .clk(clk),
    .rst(rst),
    .x_in(x),
    .sqrt_result(y)
);

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
  rst   = 1;
  x     = '0;
  #(PERIOD)
  rst = '0;
end

initial 
begin
  wait(rst == '0);
  #(PERIOD/2)
  x     <= 9;
  repeat(5)
  begin
  #(PERIOD)
  x     <= $urandom_range(1,255);
  end
 
  #(PERIOD)
  #(PERIOD)


  $stop();
end
endmodule
