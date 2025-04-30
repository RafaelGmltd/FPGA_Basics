
// The design works correctly in simulation, but during synthesis the logic gets optimized away by the synthesizer.

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

  assign x_0 = x;
  
//------------------------------------------------------------------
  genvar k;
  generate
  for (k = 0; k < STAGES; k = k + 1) 
    begin : gen_temp // <--------------------------------------------
    assign temp[k] = result[k] | (1 << ((STAGES -1) - k));
    end
  endgenerate
  
//------------------------------------------------------------------
  genvar j;
  generate
  for(j = 0; j < (STAGES -1); j = j + 1) 
    begin : gen_xreg // <--------------------------------------------
    always_ff@(posedge clk or posedge rst) 
    begin
    if (rst)
      x_reg[j] <= '0;
    else if (j == 0)
      x_reg[j] <= x_0;
    else
      x_reg[j] <= x_reg[j -1];
    end
    end
  endgenerate
  
//-------------------------------------------------------------------
  genvar i;
  generate
  for (i = 0; i < (STAGES +1); i = i + 1)
  begin : gen_main // <----------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
  if (rst) 
  begin
    data_valid[i] <= '0;
    result[i]     <= '0;
  end 
  else 
    begin
    if (i == 0) 
    begin
      data_valid[i] <= (up_valid & down_ready);
      result[1]     <= (temp[0] * temp[0] <= x_0) ? temp[0] : result[0];
    end 
    else 
      begin
      data_valid[i] <= data_valid[i -1];
      if (i == STAGES) 
      begin
        y            <= result[STAGES];
        result_valid <= data_valid[i];
      end 
      else if (data_valid[i]) 
      begin
        result[i + 1] <= (temp[i] * temp[i] <= x_reg[i - 1]) ? temp[i] : result[i];
      end
      end
      end
      end
    end
  endgenerate

endmodule