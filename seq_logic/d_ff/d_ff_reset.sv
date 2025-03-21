module d_ff_res
(
    input d,
    input clk,
    input rst,
    output logic q
);

always_ff @(posedge clk or posedge rst) 
begin

    if(rst)
      q <= 1'b0;
    else 
      q <= d;
    
end 

endmodule