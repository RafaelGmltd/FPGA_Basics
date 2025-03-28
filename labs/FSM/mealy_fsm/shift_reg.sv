module shift_reg
#(
  parameter D           = 8
)
(
input                   clk,                       
input                   rst,
input                   en,
input  [1:0]            shft_in,
output [1:0]            shft_out,
output logic[D-1:0]     shft_reg 
);

always_ff@(posedge clk or posedge rst)
    if(rst)
      shft_reg         <= '0;
    else if(en)
      shft_reg         <= {shft_in,shft_reg[D-1:2]};

assign shft_out         = shft_reg[1:0]; 

endmodule