module adder_const
#(
  parameter WIDTH = 4,
            CONS  = 1
)
( 
  input                            clk, rst,
  input  logic [WIDTH  -1:0]       x,
  output logic [WIDTH +1 :0]       y
);
  

  always_ff@(posedge clk or posedge rst)
   if(rst)
   begin
     y <= '0;
   end
  else
  begin
    y <= x + CONS;
  end 
endmodule