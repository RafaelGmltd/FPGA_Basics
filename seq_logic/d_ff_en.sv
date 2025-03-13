module  d_ff_en
(
    input d,
    input clk,
    input rst,
    input en,
    output logic q
);

    always_ff @(posedge clk or posedge rst) 
    begin

        if (rst) 
          q <= 1'b0;
        else(en)
          q <= d; 

    end
    
endmodule