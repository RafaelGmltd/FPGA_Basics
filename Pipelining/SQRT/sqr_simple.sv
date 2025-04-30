module sq_root
#( 
  parameter WIDTH = 8
)
(
input  logic                    clk,
input  logic                    rst,
input  logic [WIDTH       -1:0] x,                 // input number
output logic                    result_valid,      // result valid
output logic [(WIDTH >> 1)-1:0] y                  // root
);
logic        [(WIDTH >> 1)-1:0] result;        // current result
logic        [(WIDTH >> 1)-1:0] current_bit;   // candidate bit
logic        [(WIDTH >> 1)-1:0] temp;          // candidate root
  
// logic 
always_ff@(posedge clk or posedge rst)
  if(rst)
  begin
    current_bit  <= 1 << ((WIDTH >> 1)-1);
    result       <= '0;
    y            <= '0;
    
  end
  else
  begin
    if (result_valid)
    begin
    current_bit  <= 1<< ((WIDTH >> 1)-1);
    result       <= '0;
    y            <= result;
    end
    else
    begin
    current_bit  <= (current_bit >> 1);
      if ((temp * temp) <= x)
        result <= temp;
    end
    end
    
assign temp  = result | current_bit;
assign result_valid = (current_bit == 0) ? 1'b1 : 1'b0; 

endmodule