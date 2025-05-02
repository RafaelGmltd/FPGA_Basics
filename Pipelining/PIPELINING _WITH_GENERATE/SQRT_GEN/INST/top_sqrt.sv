//Vivado removes some parts of the logic during synthesis because certain outputs from submodules are not propagated to the top-level module outputs, 
//and are considered unused or floating, leading the tool to optimize them away

//As a solution, the bitwise square root calculation block can be instantiated directly inside the generate block — see the sqrt_top.sv file — 
//or alternatively, use the attribute (* DONT_TOUCH = "true" *)

module top_sqrt_pipeline
#(
  parameter WIDTH  = 8,
  parameter STAGES = (WIDTH >> 1)
)(
  input  logic                     clk,
  input  logic                     rst,
  input  logic [ WIDTH-1 :0]       x_in,
//  input  logic                     up_valid,
//                                   down_ready,
  output logic [ STAGES-1:0]       sqrt_result
);

  // Arrays
  logic [ WIDTH-1 :0] x_pipe       [0:STAGES];
  logic [ WIDTH-1:0] result_pipe   [0:STAGES];
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
      valid_pipe [0] <= 1'b1 /*(up_valid & down_ready)*/;
    end 
  end
  
  genvar i;
  generate
    for (i = 0; i < STAGES; i = i + 1) 
    begin: sqrt_stages
    //(* DONT_TOUCH = "true" *)
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
  
//  always @(posedge clk) 
//  begin
//  $display("Time: %0t |x_pipe[i]: %d |x_pipe[1]: %d |x_pipe[2]: %d |x_pipe[3]: %d |x_pipe[4]: %d", $time,
//           x_pipe[i], x_pipe[1], x_pipe[2], x_pipe[3],x_pipe[4]);
//  $display("Time: %0t |valid_pipe[0]: %d |valid_pipe[1]: %d |valid_pipe[2]: %d |valid_pipe[3]: %d |valid_pipe[4]: %d", $time,
//           valid_pipe[0], valid_pipe[1], valid_pipe[2], valid_pipe[3],valid_pipe[4]);
//  $display("Time: %0t |bit_pipe[0]: %d |bit_pipe[1]: %d |bit_pipe[2]: %d  |bit_pipe[3]: %d, |bit_pipe[4]: %d", $time,
//           bit_pipe[0], bit_pipe[1], bit_pipe[2], bit_pipe[3],bit_pipe[4]);
//  $display("Time: %0t |result_pipe[0]: %d, |result_pipe[1]: %d, |result_pipe[2]: %d, |result_pipe[3]: %d, |result_pipe[4]: %d", $time,
//           result_pipe[0], result_pipe[1], result_pipe[2], result_pipe[3],bit_pipe[4]);
           
//  $display("_____________________");
//  end

  assign sqrt_result = result_pipe[STAGES];
  endmodule