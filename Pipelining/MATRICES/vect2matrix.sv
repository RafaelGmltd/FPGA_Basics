`default_nettype none

module vector2matrix #(
  parameter  WIDTH     = 8,
  parameter  ROW_A     = 3,
  parameter  COL_A     = 3,
  parameter  ROW_B     = COL_A,
  parameter  COL_B     = 3

) 
(
  input  wire                                i_clk,
  input  wire                                i_rst,
  input  wire                                i_valid,
  input  wire [(WIDTH * ROW_A * COL_A)-1:0]  i_a_vect,
  input  wire [(WIDTH * ROW_B * COL_B)-1:0]  i_b_vect,

  output reg                                 o_valid,
  output reg [WIDTH-1:0]                     o_a_mat [ROW_A-1:0][COL_A-1:0],
  output reg [WIDTH-1:0]                     o_b_mat [ROW_B-1:0][COL_B-1:0]
);

always_ff @(posedge i_clk or posedge i_rst) 
begin
  if (i_rst) 
  begin
    o_valid <= 1'b0;
  end 
  else 
  begin
    if (i_valid) 
    begin
      for (int i = 0; i < ROW_A; i++) 
      begin
        for (int j = 0; j < COL_A; j++) 
        begin
          o_a_mat[i][j] <= i_a_vect[((i * COL_A + j) * WIDTH) +: WIDTH];
        end
      end
      
      for (int i = 0; i < ROW_B; i++) 
      begin
        for (int j = 0; j < COL_B; j++) 
        begin
          o_b_mat[i][j] <= i_b_vect[((i * COL_B + j) * WIDTH) +: WIDTH];
        end
      end
      
      o_valid <= 1'b1;
    end 
    else 
    begin
      o_valid <= 1'b0;
    end
  end
end


endmodule
