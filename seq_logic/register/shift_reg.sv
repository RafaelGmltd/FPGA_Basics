module shift_reg 
#(
    parameter W = 4
) 
(
    input clk, rst,
    input d_in,
    output logic q_out 

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

//shifting to right logic 
    assign r_next = {d_in,r_reg[W-1:1]};  
    assign q_out = r_reg[0]; //serial out

// 1clk r_reg = 1111 d_in = 0 r_next = 0111 q_out = 1
// 2clk r_reg = 0111 d_in = 0 r_next = 0011 q_out = 1
// 3clk r_reg = 0011 d_in = 0 r_next = 0001 q_out = 1
// 4clk r_reg = 0001 d_in = 0 r_next = 0000 q_out = 1
// 5clk r_reg = 0000 d_in = 1 r_next = 1000 q_out = 0
//etc....

    
endmodule