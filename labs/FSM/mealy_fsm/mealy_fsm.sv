module mealy_fsm
(
input                       clk,
input                       rst,
input                       en,
input [1:0]                 in_mealy,
output                      out_mealy,
output logic [1:0]          state_mealy
);

typedef enum bit [1:0]
{

    S0 = 2'd0,
    S1 = 2'd1,
    S2 = 2'd2,
    S3 = 2'd3
  
}
state_fsm;
state_fsm state,next_state;

// State register
always_ff@(posedge clk or posedge rst)
  if(rst)
    state       <= S2;
  else if(en)
 
    state       <= next_state;

// Next state logic   
always_comb
    begin
        next_state = state;

        case (state)
        S0: if      (in_mealy == 2'd2)              next_state = S1;
            else if (in_mealy == 2'd1)              next_state = S3;
            else if (in_mealy == 2'd3)              next_state = S2;

        S1: if      (in_mealy == 2'd2)              next_state = S3;
            else if (in_mealy == 2'd1)              next_state = S0;
            else if (in_mealy == 2'd3)              next_state = S2;

        S2: if      (in_mealy == 2'd2)              next_state = S0;
            else if (in_mealy == 2'd1)              next_state = S1;
            else if (in_mealy == 2'd3)              next_state = S3;

        S3: if      (in_mealy == 2'd2)              next_state = S0;
            else if (in_mealy == 2'd1)              next_state = S1;
            else if (in_mealy == 2'd3)              next_state = S2;
           

        endcase
    end

    // Output logic based on current state
    assign out_mealy   = (state == S0)&((in_mealy == 2'd1)|(in_mealy == 2'd2))|
                         (state == S1 &                    (in_mealy == 2'd1))|
                         (state == S2 &                    (in_mealy == 2'd0));
    assign state_mealy = state;
endmodule