module sqrt
#( 
  parameter WIDTH =         16
)
(
input  logic                    clk,
input  logic                    rst,
input  logic                    start,
input  logic [WIDTH       -1:0] x,                 // input number

output logic                    result_valid,    // result valid
output logic [(WIDTH >> 2)-1:0] y               // root
);
logic        [WIDTH       -1:0] x_reg;
logic        [(WIDTH >> 2)-1:0] result;        // current result
logic        [(WIDTH >> 2)-1:0] current_bit;  // candidate bit
logic        [(WIDTH >> 2)-1:0] temp;        // candidate root

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
  begin
    state <= START;
  end 
else 
    state <= next_state;
  end

// Next state logic
always_comb begin
    next_state = state;
    case (state)
    START: if (start)               next_state = CALC;
    CALC : if (current_bit == 0)    next_state = DONE;
    DONE : if (start)               next_state = START;
    endcase
    end

// Reg state
always_ff @(posedge clk or posedge rst) begin
if (rst) 
  begin
    result      <= '0;
    current_bit <= 1 << (WIDTH >> 2)-1;  // start MSB
    x_reg       <= '0;
  end 
else 
  begin
    case (state)
    START:if (start) begin           x_reg        <= x;
                                     result       <= 0;
                                     current_bit  <= 1 << (WIDTH >> 2)-1;
                      end
    CALC:             begin          temp = result | current_bit;
                                     if ((temp * temp) <= x_reg) 
                                     begin
                                     result        <= temp;
                                     end
                                     current_bit   <= current_bit >> 1; // shift bit
                      end
    default;
    endcase
  end
end

assign y            = result;
assign result_valid = (state == DONE);

endmodule