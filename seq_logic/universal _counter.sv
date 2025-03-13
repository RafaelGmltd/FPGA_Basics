module univ_counter 
#(
    parameter W = 8
) 
(
    input                  clk, rst, 
    input         clr, en, up, load,
    input [W-1:0]                 d,
    output logic max_tick, min_tick,
    output logic [W-1:0]           q
);
    logic  [W-1:0] r_reg, r_next;

    always_ff @(posedge clk or posedge rst) 
    begin
        if(rst)
          r_reg <= '0;
        else
          r_reg <= r_next;    
    end
    
    always_comb
        if(clr)
          r_next = '0;
        else if(load)
          r_next = d;
        else if(en & up)
          r_next = r_reg + 1;
        else if(en & ~up)
          r_next = r_reg - 1;
        else
        r_next = r_reg;

    assign q = r_reg;
    assign max_tick = (r_reg == {W{1'b1}});
    assign min_tick = (r_reg == '0);
    
endmodule