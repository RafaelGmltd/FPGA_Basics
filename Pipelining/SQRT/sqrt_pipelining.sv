module sq_root
#( 
  parameter WIDTH = 8
)
(
  input  logic                    clk,
  input  logic                    rst,
  input  logic                    up_valid,
                                  down_ready,
  input  logic [WIDTH       -1:0] x,
  output logic                    result_valid,
  output logic [(WIDTH >> 1)-1:0] y
);
  localparam STAGES = (WIDTH >> 1);
  
  logic [STAGES -1     :0] result     [0:  STAGES    ];
  logic [WIDTH  -1     :0] x_reg      [0: (STAGES -2)];
  logic                    data_valid [0:  STAGES    ];
  logic [STAGES -1: 0]     temp       [0: (STAGES -1)];
  logic [WIDTH  -1     :0] x_0;
  
  genvar i;
  generate
  begin
  for (i = 0; i < STAGES; i = i + 1)
    assign temp[i] = result[i] | (1 << ((STAGES -1) - i));
  end
  endgenerate
  
//  assign temp[0] = result[0] |     (1 << (STAGES -1)); // 1000
//  assign temp[1] = result[1] |     (1 << (STAGES -2)); // 0100
//  assign temp[2] = result[2] |     (1 << (STAGES -3)); // 0010
//  assign temp[3] = result[3] |     (1 <<          '0); // 0001

  assign x_0 = x;

  always_ff @(posedge clk or posedge rst) 
   begin
    if (rst) 
     begin
      result_valid <= '0;
      y            <= '0;

      result[0] <= '0;
      result[1] <= '0;
      result[2] <= '0;
      result[3] <= '0;
      result[4] <= '0;

      x_reg[0] <= '0;
      x_reg[1] <= '0;
      x_reg[2] <= '0;

      data_valid[0] <= '0;
      data_valid[1] <= '0;
      data_valid[2] <= '0;
      data_valid[3] <= '0;
      data_valid[4] <= '0;
    end 
    else
     begin
      data_valid[0] <= (up_valid & down_ready);
      data_valid[1] <= data_valid[0];
      data_valid[2] <= data_valid[1];
      data_valid[3] <= data_valid[2];
      data_valid[4] <= data_valid[3];

      // x pipeline
      x_reg[0] <= x_0;
      x_reg[1] <= x_reg[0];
      x_reg[2] <= x_reg[1];

      // bitwise
      if (data_valid[0])
        result[1] <= (temp[0] * temp[0] <= x_0) ? temp[0] : result[0];
      if (data_valid[1])
        result[2] <= (temp[1] * temp[1] <= x_reg[0]) ? temp[1] : result[1];
      if (data_valid[2])
        result[3] <= (temp[2] * temp[2] <= x_reg[1]) ? temp[2] : result[2];
      if (data_valid[3])
        result[4] <= (temp[3] * temp[3] <= x_reg[2]) ? temp[3] : result[3];

      // final
      if (data_valid[4]) 
       begin
        y <= result[4];
        result_valid <= 1'b1;
       end 
      else 
       begin
        result_valid <= '0;
       end
     end
   end

endmodule

