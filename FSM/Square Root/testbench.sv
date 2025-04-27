module sqrt_tb;

localparam      WIDTH             = 16;
logic                             clk;
logic                             rst;
logic                             start;
logic                             result_valid;
logic [(WIDTH >> 1)-1:0]          y;
logic [ WIDTH      -1:0]          x;


sqrt
#(.WIDTH(WIDTH))
dut
(   .clk(clk),
    .rst(rst),
    .start(start),
    .x(x),
    .result_valid(result_valid),
    .y(y)
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
  start = '0;
  x     = '0;
  
  #(PERIOD)
  rst = '0;
end

initial 
begin
  wait(rst == '0);

  @(posedge clk);
  start <= 1;
  x     <= 25;
  @(posedge clk);
  start <= '0;
  
      repeat(5)
      begin
      wait(result_valid == 1);
      start <= '1;
      x     <= $urandom_range(1, 65535);
      @(posedge clk);
      start <= '0;
      wait(result_valid == 0);
      end
  
  wait(result_valid == 1);
  @(posedge clk);
  start <= '0;
  #(PERIOD)
  
  $stop();
end
endmodule