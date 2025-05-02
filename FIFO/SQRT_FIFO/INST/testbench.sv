module testbench;

localparam      WIDTH_A             = 8;
localparam      WIDTH_B             = 8;
localparam      WIDTH_C             = 16;

logic                             clk;
logic                             rst;
logic [ WIDTH_A      -1:0]        x_1;
logic [(WIDTH_A >> 1)-1:0]        y_1;
logic                             result_valid_1;

logic [ WIDTH_B       -1:0]       x_2;
logic [(WIDTH_B >> 1)-1:0]        y_2;
logic                             result_valid_2;

logic [ WIDTH_C      -1:0]        x_3;
logic [(WIDTH_C >> 1)-1:0]        y_3;
logic                             result_valid_3;

logic [WIDTH_C -1      :0]        sum; 



sqrt_a_b_c
#(.WIDTH_A(WIDTH_A),
  .WIDTH_B(WIDTH_B),
  .WIDTH_C(WIDTH_C)
  )
dut
(   .clk            (clk),
    .rst            (rst),
    
    .a              (x_1),
    .result_a       (y_1),
    .result_a_valid (result_valid_1),
    
    .b              (x_2),
    .result_b       (y_2),
    .result_b_valid (result_valid_2),  
    
    .c              (x_3),
    .result_c       (y_3),
    .result_c_valid (result_valid_3), 
    
    .sum(sum) 
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
  x_1     = '0;
  x_2     = '0;
  x_3     = '0;
  #(PERIOD)
  rst = '0;
end

initial 
begin
  wait(rst == '0);
  #(PERIOD/2)
  x_1     <= 25;
  x_2     <= 16;
  x_3     <= 9;
  
  repeat(8)
  begin
  #(PERIOD)
  x_1     <= $urandom_range(1,64);
  x_2     <= $urandom_range(64,120);
  x_3     <= $urandom_range(255,300);
  end
 
  #150

  $stop();
end
endmodule