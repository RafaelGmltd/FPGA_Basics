module add_1
(
input        a,
input        b,
input        cin,      
output logic sum,
output logic cout    
);
    
wire x_o_1, x_o_2, x_o_3;

assign x_o_1 = a & b;        // AND operation
assign x_o_2 = a ^ b;        // XOR operation
assign x_o_3 = a & b;        // AND operation
assign sum = cin ^ x_o_2;    // XOR operation
assign cout = x_o_3 | x_o_1; // OR operation

endmodule

// or we can write this in a more trivial form using Boolean functions for the full adder with carry
// result will be same

/*
module add_1
(
input        a,
input        b,
input        cin,      
output logic sum,
output logic cout    
);
    
assign sum = a ^ b cin;
assign cout = a & b | (a ^ b) & cin;

endmodule
*/
