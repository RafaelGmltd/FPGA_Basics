module moore_fsm
(
    input                clk,
    input                rst,
    input                en,
    input  [1:0]         x,
    output               y1,y0,
    output logic [2:0]   y
);

    typedef enum bit [2:0]
    {
        S0 = 3'd0,
        S1 = 3'd1,
        S2 = 3'd2,
        S3 = 3'd3,
        S4 = 3'd4
    }
    state_e;

    state_e state, next_state;

    // State register

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            state <= S0;
        else if (en)
        begin
            state <= next_state;
            y <= next_state;
        end
    // Next state logic

    always_comb
    begin
        next_state = state;

        case (state)
        S0: if      (x == 2'd1)              next_state = S2;
            else if (x == 2'd2 | x== 2'd3)   next_state = S1;

        S1: if      (x == 2'd1)              next_state = S3;
            else if (x == 2'd2)              next_state = S0;
            else if (x == 2'd3)              next_state = S2;

        S2: if      (x == 2'd0)              next_state = S4;
            else if (x == 2'd1)              next_state = S1;
            else if (x == 2'd2)              next_state = S0;

        S3: if      (x == 2'd0)              next_state = S4;
            else if (x == 2'd1)              next_state = S1;
            else if (x == 2'd2)              next_state = S0;
            else                             next_state = S2;

        S4: if      (x == 2'd2)              next_state = S0;
            else if (x == 2'd1)              next_state = S3;
            else if (x == 2'd3)              next_state = S2;

        endcase
    end

    // Output logic based on current state
    assign y = state;
    assign y1 = (state == S0 & (x == 2'd0 | 2'd1))|
                (state == S2 & (x == 2'd3 | 2'd0))| 
                (state == S4 & (x == 2'd0 | 2'd3));
    
    assign y0 = (state == S2 & (x == 2'd3 | 2'd0))| 
                (state == S4 & (x == 2'd0 | 2'd3));

endmodule