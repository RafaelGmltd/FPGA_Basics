module univ_shift_reg 
#(
  parameter W = 8
) 
(
input                 clk, 
                      rst,
input        [1   :0] cntrl,
input        [W-1 :0] d_in,
output logic [W-1 :0] q_out
);
logic [W-1 :0]        r_reg;
logic [W-1 :0]        r_next;

always_ff @(posedge clk or posedge rst ) 
begin
  if(rst)
    r_reg <= '0;
  else
    r_reg <= r_next;
end

always_comb 
begin
  case (cntrl)
    2'b00: r_next   =  r_reg;
    2'b01: r_next   = {r_reg[W-2:0],   d_in[0]};  //shift operation left
    2'b10: r_next   = {d_in[W-1], r_reg[W-1:1]};  //shift operation right
    default: r_next =  d_in;                      //parallel load
    endcase    
end

assign  q_out = r_reg;

endmodule