module sqrt
#( 
  parameter WIDTH = 16
)
(
input  logic                    clk,
input  logic                    rst,
input  logic                    start,
input  logic [WIDTH       -1:0] x,             // input number
output logic                    result_valid,  // result valid
output logic [(WIDTH >> 1)-1:0] y              // root
);
logic        [ WIDTH      -1:0] x_reg;
logic        [(WIDTH >> 1)-1:0] result;        // current result
logic        [(WIDTH >> 1)-1:0] current_bit;   // candidate bit
logic        [(WIDTH >> 1)-1:0] temp;          // candidate root

typedef enum bit [1:0] 
{
  START,
  CALC,
  DONE
} 
state_t;
state_t state, next_state;

// State register
always_ff @(posedge clk or posedge rst) begin
  if (rst)
    state <= START;
  else 
    state <= next_state;
end

// Next state logic
always_comb 
begin
next_state = state;
case (state)
  START: if (start)                next_state = CALC;
  CALC : if (current_bit  == '0)   next_state = DONE;  
  DONE :                           next_state = START;
 endcase
end

// Reg state
always_ff @(posedge clk or posedge rst) 
begin
if (rst) 
begin
  result       <= '0;
  current_bit  <=  1 << ((WIDTH >> 1)-1);  // start MSB
  x_reg        <= '0;
  y            <= '0;
  result_valid <=  1'b0;
end 
else 
begin
  case (state)
    START: if (start) 
    begin
      x_reg        <=  x;
      result       <= '0;
      current_bit  <=  1 << ((WIDTH >> 1)-1);
      y            <= '0;
      result_valid <=  1'b0;
    end
    CALC:  
    begin
      temp = result | current_bit;
      if ((temp * temp) <= x_reg) 
        result          <= temp;
        current_bit     <= current_bit >> 1; // shift bit
    end
    DONE:  
    begin
      y            <= result;          
      result_valid <= 1'b1;  
    end
  endcase
end
end

// Debug only
always_ff @(posedge clk) begin
  if (state == CALC) begin
    $display("[%0t ns] state: %0d, x_reg: %0d, result: %0d, current_bit: %0d, temp: %0d", $time, state, x_reg, result, current_bit, temp);
  end
  else if (state == DONE) begin 
    $display("[%0t ns] sqrt(%0d) = %0d", $time, x_reg, result);
  end
end

endmodule