module node
#(
  parameter WEIGHT_W   = 8,
  parameter X_DATA_W   = 8,
  parameter PREV_SUM_W = 8,
  parameter NEXT_SUM_W = 17
)
(
  input  logic                   i_clk,
  input  logic                   i_rst,
  input  logic [WEIGHT_W   -1:0] i_weight,
  input  logic [X_DATA_W   -1:0] i_x_data,
  input  logic [PREV_SUM_W -1:0] i_psumm,
    
  output logic [NEXT_SUM_W -1:0] o_nsumm,
  output logic [X_DATA_W   -1:0] o_x_data
);

logic [X_DATA_W            -1:0] x_reg;
logic [NEXT_SUM_W          -1:0] summ_reg;
logic [X_DATA_W + X_DATA_W -1:0] weight_mult;

assign weight_mult = i_x_data * i_weight;

always_ff @(posedge i_clk or posedge i_rst) 
begin
  if (i_rst)
  begin
    summ_reg <= '0;
  end
  else
    summ_reg <= i_psumm + weight_mult;
end

always_ff @(posedge i_clk or posedge i_rst) 
begin
  if (i_rst)
  begin
    x_reg <= '0;
  end
  else
    x_reg <= i_x_data;
end

assign o_nsumm  = summ_reg;
assign o_x_data = x_reg;

endmodule