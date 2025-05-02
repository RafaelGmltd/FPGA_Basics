module top_sqrt
#(
  parameter WIDTH  = 32,
  parameter STAGES = (WIDTH >> 1)
)(
  input  logic                     clk,
  input  logic                     rst,
  input  logic [ WIDTH-1 :0]       x_in,

  
//  input  logic                     up_valid,
//                                   down_ready,
  output logic [ STAGES-1:0]       sqrt_result,
  output logic                     result_valid                    
);

  // Arrays
  logic [ WIDTH -1:0] x_pipe       [0:STAGES];
  logic [ WIDTH -1:0] result_pipe  [0:STAGES];
  logic [ WIDTH -1:0] bit_pipe     [0:STAGES];
  logic               valid_pipe   [0:STAGES];

  // First Step
  always_ff @(posedge clk or posedge rst) 
  begin
    if (rst) begin
      x_pipe     [0] <= '0;
      result_pipe[0] <= '0;
      bit_pipe   [0] <= '0;
    end else begin
      x_pipe     [0] <= x_in;
      result_pipe[0] <= '0;
      bit_pipe   [0] <= (1 << (WIDTH - 2));
      valid_pipe [0] <= 1'b1;
    end 
  end
  
  genvar i;
  generate
    for (i = 0; i < STAGES; i = i + 1) 
    begin: sqrt_stages
    
// . . . . . . . . . . . . . . . . . . . . . . . . . .    
      logic [ WIDTH -1         :0] temp;
      assign temp = result_pipe[i] | bit_pipe[i];
      
      always_ff @(posedge clk ) 
      if( valid_pipe[i]) 
      begin
      valid_pipe[i + 1] <= valid_pipe[i];
        if (x_pipe[i] >= temp) 
        begin
          x_pipe[i+1] <= x_pipe[i] - temp;
          result_pipe[i+1] <= (result_pipe[i] >> 1) | bit_pipe[i];
        end 
        else 
        begin
          x_pipe[i+1] <= x_pipe[i];
          result_pipe[i+1] <= result_pipe[i] >> 1 ;
        end
       bit_pipe[i+1] <= (bit_pipe[i] >> 2);
      end
// . . . . . . . . . . . . . . . . . . . . . . . . . . 

  end
 endgenerate
  
  assign result_valid = valid_pipe [STAGES];
  assign sqrt_result = result_pipe[STAGES];

endmodule