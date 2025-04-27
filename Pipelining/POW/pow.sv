module pow
#(
parameter                     W = 8
)
(
input                        rst,
                             clk,
input        [W-   1:0]      num,
output logic [5*W -1:0]      pow_output     
);

logic [(2*W)-1:0] pow_2_ff;
logic [(3*W)-1:0] pow_3_ff;
logic [(4*W)-1:0] pow_4_ff;
logic [(5*W)-1:0] pow_5_ff;

logic [W-    1:0] input_0_ff;
logic [W-    1:0] input_1_ff;
logic [W-    1:0] input_2_ff;
logic [W-    1:0] input_3_ff;

    // Input data pipeline
always_ff @ (posedge clk or posedge rst)
    if (rst) 
    begin
      input_0_ff <= '0;
      input_1_ff <= '0;
      input_2_ff <= '0;
      input_3_ff <= '0;
    end
    else 
    begin
      input_0_ff <= num;
      input_1_ff <= input_0_ff;
      input_2_ff <= input_1_ff;
      input_3_ff <= input_2_ff;
    end

always_ff @ (posedge clk or posedge rst)
    if (rst) begin
      pow_2_ff <= '0;
      pow_3_ff <= '0;
      pow_4_ff <= '0;
      pow_5_ff <= '0;
    end
    else begin
      pow_2_ff <= input_0_ff * input_0_ff;
      pow_3_ff <= input_1_ff * pow_2_ff ;
      pow_4_ff <= input_2_ff * pow_3_ff;
      pow_5_ff <= input_3_ff * pow_4_ff;
    end
    
assign pow_output = pow_5_ff;
endmodule
