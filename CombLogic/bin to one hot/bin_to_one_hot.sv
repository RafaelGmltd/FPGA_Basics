module bin_to_onehot 
#(
  parameter   WIDTH = 3                // Input width (number of bits in bin)
)
(
input        [ WIDTH    -1:0] bin,     // Binary input
output logic  [(1<<WIDTH)-1:0] onehot  // One-hot encoded output
);

always_comb 
begin
  onehot      = '0;                    // Set all bits to 0 by default
  onehot[bin] = 1'b1;                  // Set one active bit based on the binary input
end

endmodule
