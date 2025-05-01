module top_sqrt_pipeline
#(
  parameter WIDTH  = 8,
  parameter STAGES = (WIDTH >> 1) // WIDTH/2 
)(
  input  logic                     clk,
  input  logic                     rst,
  input  logic [ WIDTH-1 :0]       x_in,
  input  logic                     up_valid,
                                   down_ready,
  output logic [ STAGES-1:0]       sqrt_result
);

  // Arrays
  logic [ WIDTH-1 :0] x_pipe       [0:STAGES];
  logic [ STAGES-1:0] result_pipe  [0:STAGES];
  logic [ STAGES-1:0] bit_pipe     [0:STAGES];
  logic               valid_pipe   [0:STAGES];

  // First state
  always_ff @(posedge clk or posedge rst) 
  begin
    if (rst) begin
      x_pipe     [0] <= '0;
      result_pipe[0] <= '0;
      bit_pipe   [0] <= (1 << (STAGES - 1));
    end else begin
      x_pipe     [0] <= x_in;
      result_pipe[0] <= '0;
      bit_pipe   [0] <= (1 << (STAGES - 1));
      valid_pipe [0] <= (up_valid & down_ready);
    end 
  end
  
  genvar i;
  generate
    for (i = 0; i < STAGES; i = i + 1) 
    begin: sqrt_stages
      sq_root_stage
      #(
        .WIDTH(WIDTH)
      ) 
      sq_stage_i 
      (
        .clk             (clk),
        .rst             (rst),
        .x               (x_pipe[i]),         // Input x current state
        .result_in       (result_pipe[i]),    // Input result current state
        .current_bit_in  (bit_pipe[i]),       // Input bit mask current state
        .data_valid_in   (valid_pipe[i]),
        
        .data_valid_out  (valid_pipe[i+1]),
        .x_out           (x_pipe[i+1]),       // Output x next state
        .result_out      (result_pipe[i+1]),  // Output result current state
        .current_bit_out (bit_pipe[i+1])      // Output bit mask current state
      );
    end
  endgenerate

  assign sqrt_result = result_pipe[STAGES];
  endmodule