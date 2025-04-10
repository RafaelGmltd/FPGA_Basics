module nested_radicals
#( 
  parameter WIDTH =         16
)
(
input  logic                    clk,
input  logic                    rst,
input  logic                    start,
input  logic [WIDTH       -1:0] a,b,c,                 // input number

output logic                    result_valid,    // result valid
output logic [(WIDTH >> 1)-1:0] y, 
output logic [WIDTH       -1:0] sum             // root
);
logic        [WIDTH       -1:0] x_reg;
logic        [(WIDTH >> 1)-1:0] result;        // current result
logic        [(WIDTH >> 1)-1:0] current_bit;  // candidate bit
logic        [(WIDTH >> 1)-1:0] temp;        // candidate root
logic        [1:0             ] cntr;
logic [(WIDTH >> 1)-1:0] sum_out; 
typedef enum bit [1:0] 
{
  START,
  SQRT,
  SUM,
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
    START: if (start)               next_state = SQRT;
    SQRT : if (current_bit == 0)    next_state = SUM;
    SUM  : if (cntr == 2'd3    )    next_state = DONE;
           else if(cntr != 2'd3)    next_state = SQRT;
    DONE : if (start)               next_state = START;
    endcase
    end

// Reg state
always_ff @(posedge clk or posedge rst) begin
if (rst) 
  begin
    result      <= '0;
    current_bit <= 1 << ((WIDTH >> 1)-1);  // start MSB
    x_reg       <= '0;
    cntr        <= '0;
    y           <= '0;
    sum         <= '0;
  end 
else 
  begin
    case (state)
    START:if (start) begin           x_reg        <=  c;
                                     result       <= '0;
                                     current_bit  <= 1 << ((WIDTH >> 1)-1);
                                     
                      end
    SQRT:             begin          temp = result | current_bit;
                                     if ((temp * temp) <= x_reg) 
                                     begin
                                     result        <= temp;
                                     end 
                                     current_bit   <= current_bit >> 1; // shift bit
                                     if (current_bit == 0)
                                     begin
                                     y             <= result;
                                     cntr          <= cntr + 1'b1;
                                     end
                      end
    SUM :                            if (cntr == 2'd1)
                                     begin
                                     x_reg         <= y + b;
                                     result        <= 0;
                                     current_bit   <= 1 << ((WIDTH >> 1)-1); 
                                     end
                                     else if  (cntr == 2'd2)
                                     begin
                                     x_reg         <= y + a;
                                     result        <= 0;
                                     current_bit   <= 1 << ((WIDTH >> 1)-1);
                                     end
                      
    DONE: begin
          end                           
    endcase
  end
end
assign sum = x_reg;
assign result_valid = (current_bit == 128);

endmodule
