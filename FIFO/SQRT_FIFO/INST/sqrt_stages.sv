module sq_root_stage 
#(
  parameter WIDTH = 8,
            STAGES = (WIDTH >> 1)
)(
  input  logic                  clk,
  input  logic                  rst,
  input  logic [ WIDTH -1   :0] x,
  input  logic [ WIDTH -1   :0] result_in,
  input  logic [ WIDTH -1   :0] current_bit_in,
  input  logic                  data_valid_in,

  output logic [ WIDTH -1   :0] x_out,
  output logic [ WIDTH -1   :0] result_out,
  output logic [ WIDTH -1   :0] current_bit_out,
  output logic                  data_valid_out,
  output logic                  result_valid_out
);
  localparam [ STAGES -1:0] max  = STAGES'(STAGES);
  logic      [ STAGES -1:0] cnt;
  
  logic [ WIDTH  -1        :0] temp;
  assign temp = result_in | current_bit_in;
  
  always_ff @(posedge clk ) 
  if(data_valid_in) 
  begin
    data_valid_out  <= data_valid_in;
    if (x >= temp) 
    begin
      x_out <= x - temp;
      result_out <= (result_in >> 1) | current_bit_in;
    end 
    else 
    begin
      x_out <= x;
      result_out <= result_in >> 1 ;
    end
   current_bit_out <= (current_bit_in >> 2);
   end
   
 // For debbug
   always_ff@(posedge clk or posedge rst)
   if(rst)
     begin
     cnt              <= '0;
     result_valid_out <= '0;
     end
   else if(cnt == max)
     begin
     result_valid_out <= 1'b1;
     cnt              <= '0;
     end
   else
     cnt              <= cnt + 1'b1;
     

  

  always_ff@(posedge clk)
  begin
    $display("Time: %0t |x: %0d   |result_in: %0d   |current_bit_in: %0d   |x_out: %0d   |result_out: %0d   |current_bit_out: %0d, |temp: %0d, |x>=temp=%b, |data_valid_in: %0d, |result_valid_out: %0d ", 
    $time, x, result_in, current_bit_in, x_out, result_out, current_bit_out,temp,(x >= temp), data_valid_in, result_valid_out);
    $display("_____________________");
  end

endmodule