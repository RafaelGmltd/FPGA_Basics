 module top_module
#(
  parameter WIDTH                  = 4,
            STAGES                 = 5,
            CONS                   = 2
)
( 
  input                            clk, rst,
  input  logic [ WIDTH +1:0]       first_x,
  output logic [ WIDTH +1:0]       result_y
);
  
  logic [WIDTH +1:0] result_reg [0:STAGES];
  
  always_ff@(posedge clk or posedge rst)
    if(rst)
      result_reg [0] <= '0;
    else
      result_reg [0] <= first_x;
      
  
  genvar i;
  generate
  for(i = 0; i < STAGES;i = i + 1)
    begin: adder_pipe
    
    adder_const
    #(.WIDTH(WIDTH),
      .CONS(CONS)
      )
    adder_i
    (
      .clk(clk),
      .rst(rst),
      .x  (result_reg[i]),
      .y  (result_reg[i +1])
    );
    end
  endgenerate
  
  assign result_y = result_reg[STAGES];
  
endmodule
