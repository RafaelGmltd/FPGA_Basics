module testbench;

localparam      WIDTH             = 4;
logic                             clk;
logic                             rst;
logic                             result_valid;
logic [ WIDTH      -1:0]          x;
logic [(WIDTH >> 1)-1:0]          y;



sq_root
#(.WIDTH(WIDTH))
dut
(   .clk(clk),
    .rst(rst),
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
  x     = '0;
  #(PERIOD)
  rst = '0;
end

initial 
begin
  wait(rst == '0);
  x     <= 12;
  repeat(23)
  begin
  wait(result_valid == 1);
  wait(result_valid == 0);
  x     <= $urandom_range(1,9);
  end
  
  #(PERIOD)
  
  $stop();
end
endmodule