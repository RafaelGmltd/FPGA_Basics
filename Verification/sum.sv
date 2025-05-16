module sum (
input  logic       clk,
input  logic       rst,
input  logic [7:0] a,
input  logic [7:0] b,
output logic [7:0] c
);

always_ff @( posedge clk or posedge rst) 
begin
if(rst) 
  c <= 'b0;
else 
  c <= a + b;
end

endmodule