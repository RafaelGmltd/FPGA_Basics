module mealy_fsm
(
    input               clk,
    input               rst,
    input               en,
    input  [1:0]        x,
    output              y_out,
    output logic [1:0]  y
);

    typedef enum bit [1:0]
    {
        S0 = 2'd0,
        S1 = 2'd1,
        S2 = 2'd2,
        S3 = 2'd3

    }
    state_e;

    state_e state, next_state;

    // State register

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            state <= S2;
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
        S0: if      (x == 2'd0)              next_state = S1;
            else if (x == 2'd1)              next_state = S3;
            else if (x == 2'd3)              next_state = S2;

        S1: if      (x == 2'd0)              next_state = S3;
            else if (x == 2'd1)              next_state = S0;
            else if (x == 2'd3)              next_state = S2;

        S2: if      (x == 2'd0)              next_state = S0;
            else if (x == 2'd1)              next_state = S1;
            else if (x == 2'd3)              next_state = S3;

        S3: if      (x == 2'd0)              next_state = S0;
            else if (x == 2'd1)              next_state = S1;
            else if (x == 2'd3)              next_state = S2;
           

        endcase
    end

    // Output logic based on current state
    assign y     =                              state;
    assign y_out = (state == S0 & (x == 2'd1 | 2'd2))|
                   (state == S1 & (x == 2'd1)       )|
                   (state == S2 & (x == 2'd0)       );


endmodule