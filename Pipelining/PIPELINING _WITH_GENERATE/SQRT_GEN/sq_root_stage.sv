module sq_root_stage 
#(
  parameter WIDTH = 8,
            STAGES = (WIDTH >> 1) // WIDTH/2
)(
  input  logic                  clk,
  input  logic                  rst,
  input  logic [ WIDTH -1   :0] x,
  input  logic [ STAGES-1   :0] result_in,
  input  logic [ STAGES-1   :0] current_bit_in,
  input  logic                  data_valid_in,

  output logic [ WIDTH-1    :0] x_out,
  output logic [ STAGES-1   :0] result_out,
  output logic [ STAGES-1   :0] current_bit_out,
  output logic                  data_valid_out

);

  logic [ STAGES -1         :0] temp;
  
  assign temp = result_in | current_bit_in;
  
  always_ff @(posedge clk ) 
  if(data_valid_in) 
  begin
    data_valid_out  <= data_valid_in;
    x_out           <= x;
    result_out      <= (temp * temp <= x) ? temp : result_in;
    current_bit_out <= (current_bit_in >> 1);
  end

endmodule