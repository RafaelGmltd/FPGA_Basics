module moore_fsm
(
input                       clk,
input                       rst,
input                       en,
input        [1:0]          in_moore,
output       [1:0]          out_moore,
output logic [2:0]          state_moore
);

typedef enum bit[2:0]
{
  
  S0 = 3'd0,
  S1 = 3'd1,
  S2 = 3'd2,
  S3 = 3'd3,
  S4 = 3'd4
}
state_fsm;
state_fsm state, next_state;

//State register
    always_ff @ (posedge clk or posedge rst)
        if (rst)
            state <= S1;
        else if (en)
            state <= next_state;
 // Next state logic       
    always_comb
    begin
        next_state = state;

        case (state)
        S0: if      (in_moore == 2'd1)              next_state = S2;
            else if (in_moore == 2'd2 | 
                     in_moore == 2'd3)              next_state = S1;

        S1: if      (in_moore == 2'd1)              next_state = S3;
            else if (in_moore == 2'd2)              next_state = S0;
            else if (in_moore == 2'd3)              next_state = S2;

        S2: if      (in_moore == 2'd0)              next_state = S4;
            else if (in_moore == 2'd1)              next_state = S1;
            else if (in_moore == 2'd2)              next_state = S0;

        S3: if      (in_moore == 2'd0)              next_state = S4;
            else if (in_moore == 2'd1)              next_state = S1;
            else if (in_moore == 2'd2)              next_state = S0;
            else                                    next_state = S2;

        S4: if      (in_moore == 2'd2)              next_state = S0;
            else if (in_moore == 2'd1)              next_state = S3;
            else if (in_moore == 2'd3)              next_state = S2;

        endcase
    end

    // Output logic based on current state
    assign out_moore[1] =   (state == S0 & (in_moore == 2'd0 | 2'd1))|
                            (state == S2 & (in_moore == 2'd3 | 2'd0))| 
                            (state == S4 & (in_moore == 2'd0 | 2'd3));
    
    assign out_moore[0] =   (state == S2 & (in_moore == 2'd3 | 2'd0))| 
                            (state == S4 & (in_moore == 2'd0 | 2'd3) );
    assign state_moore  =    state;                       

endmodule