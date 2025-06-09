module test;

  parameter WEIGHT_W    = 8;
  parameter X_DATA_W    = 8;
  parameter NUM_MACS    = 3;

 logic                                         i_clk;
 logic                                         i_rst;
 logic [X_DATA_W -1:0]                         x1;
 logic [X_DATA_W -1:0]                         x2;
 logic [X_DATA_W -1:0]                         x3;
 logic [(WEIGHT_W + X_DATA_W + NUM_MACS) -1:0] y1;
 logic [(WEIGHT_W + X_DATA_W + NUM_MACS) -1:0] y2;
 logic [(WEIGHT_W + X_DATA_W + NUM_MACS) -1:0] y3;
 
matrices_mult 
#(
  .WEIGHT_W (WEIGHT_W ),
  .X_DATA_W (X_DATA_W ),
  .NUM_MACS (NUM_MACS )
) 
dut 
(
  .i_clk(i_clk ),
  .i_rst(i_rst ),
  .x1   (x1    ),
  .x2   (x2    ),
  .x3   (x3    ),
  .y1   (y1    ),
  .y2   (y2    ),
  .y3   (y3    )
);

parameter CLK_PERIOD = 10;

initial begin
  i_clk = 0;
  forever #(CLK_PERIOD / 2) i_clk = ~i_clk;
end

initial 
begin
  i_rst = 1'b1;
  #(CLK_PERIOD);
  i_rst = 1'b0;
  x1 = '0;
  x2 = '0;
  x3 = '0;
end

initial 
begin
wait (!i_rst);
@(posedge i_clk);
x1 <= 8'd4;
@(posedge i_clk);
x2 <= 8'd6;
@(posedge i_clk);
x3 <= 8'd3;
@(posedge i_clk);

#(10);
$finish();
 end
 
endmodule