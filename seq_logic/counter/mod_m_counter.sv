module mod_m_counter 
#(
    parameter W = 4, // number of bits in cntr
              D = 10 // mod m of cntr 
) 
(
    input clk, rst,
    output logic max_tick,
    output logic [W-1:0] q

);
    logic [W-1:0] r_reg;
    logic [W-1:0] r_next;

    always_ff @(posedge clk or posedge rst) 
    begin
    if(rst)
      r_reg <= '0;
    else
      r_reg <= r_next;     
    end

    assign r_next = (r_reg == (D-1)) ? '0 : r_reg + 1;
    assign q = r_reg;
    assign max_tick = (r_reg == (D-1)) ? 1'b1 : 1'b0;
    
endmodule