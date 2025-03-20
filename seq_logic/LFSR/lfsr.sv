module random
(
    input               clk,
    input               rst,
    output logic [3:0] random
);

    // Uses LFSR, Linear Feedback Shift Register

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            random <= 4'b1111;
        else
            random <=   { random [2:0], 1'b0 }
                      ^ ( random [3] ? 4'b1001 : 4'b0);
// first { random [2:0], 1'b0 } shift left                     
// if random [3] == 1 -> random = { random [2:0], 1'b0 } XOR 4'b1001 
// if random [3] == 0 -> random = { random [2:0], 1'b0 } XOR 4'b0000 

endmodule