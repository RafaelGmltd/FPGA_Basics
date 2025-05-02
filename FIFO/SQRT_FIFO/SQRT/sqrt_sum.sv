module sqrt_a_b_c
#(
  parameter WIDTH_A  = 8,
            STAGES_A = (WIDTH_A >> 1),
            
            
            WIDTH_B  = 8,
            STAGES_B = (WIDTH_B >> 1),
            
            WIDTH_C  = 16,
            STAGES_C = (WIDTH_C >> 1),
            
            DEPTH_FIFO = ((WIDTH_C) - (WIDTH_A)) >> 1
            
)(
  input  logic                 clk,
  input  logic                 rst,

  input  logic [WIDTH_A-1:0]     a,
  input  logic [WIDTH_B-1:0]     b,
  input  logic [WIDTH_C-1:0]     c,

  output logic [STAGES_A-1:0]    result_a,
  output logic [STAGES_B-1:0]    result_b,
  output logic [STAGES_C-1:0]    result_c,

  output logic                 result_a_valid,
  output logic                 result_b_valid,
  output logic                 result_c_valid,
  
  output logic                 result_a_almost_valid,
  output logic                 result_b_almost_valid,
  output logic                 result_c_almost_valid,
  output logic [WIDTH_C -1:0]  sum
);

logic [STAGES_A-1:0] result_fifo_a;
logic [STAGES_B-1:0] result_fifo_b;


always_ff@(posedge clk or posedge rst)
  if(rst)
    sum <= '0;
  else if(result_c_valid)
    sum <= result_fifo_a + result_fifo_b + result_c;


  // sqrt  'a'

  top_sqrt 
  #(.WIDTH(WIDTH_A)) 
  sqrt_a_inst 
  (
    .clk         (clk),
    .rst         (rst),
    .x_in        (a),
    .sqrt_result (result_a),
    .result_valid(result_a_valid),
    .result_almost_valid(result_a_almost_valid)
  );
  

  fifo_valid_ready
  #(.WIDTH(STAGES_A),
    .DEPTH(DEPTH_FIFO))
  fifo_a
  (
    .clk(clk),
    .rst(rst),
    .wr_data(result_a),
    .up_valid(result_a_valid),
    .down_ready(result_c_almost_valid),
    .rd_data(result_fifo_a)
   );

  // sqrt  'b'

  top_sqrt 
  #(.WIDTH(WIDTH_B)) 
  sqrt_b_inst 
  (
    .clk         (clk),
    .rst         (rst),
    .x_in        (b),
    .sqrt_result (result_b),
    .result_valid(result_b_valid),
    .result_almost_valid(result_b_almost_valid)
  );
  
//  (* DONT_TOUCH = "true" *)
    fifo_valid_ready
  #(.WIDTH(STAGES_A),
    .DEPTH(DEPTH_FIFO))
  fifo_b
  (
    .clk(clk),
    .rst(rst),
    .wr_data(result_b),
    .up_valid(result_b_valid),
    .down_ready(result_c_almost_valid),
    .rd_data(result_fifo_b)
   );

  // sqrt 'c'
//  (* DONT_TOUCH = "true" *)
  top_sqrt 
  #(.WIDTH(WIDTH_C)) 
  sqrt_c_inst 
  (
    .clk         (clk),
    .rst         (rst),
    .x_in        (c),
    .sqrt_result (result_c),
    .result_valid(result_c_valid),
    .result_almost_valid(result_c_almost_valid)
  );

endmodule