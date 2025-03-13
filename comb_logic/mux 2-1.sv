//Structural Description
//A simple combinational logic implementation using a ternary operator

module mux2to1 
(
    input  a, b, sel,   
    output         y          
);
    assign y = sel ? b : a; 
endmodule

/*

Explicit behavior description using case

module mux2to1_case 
(
    input  a, b, sel, 
    output logic   y
);
    always_comb 
    begin
    case (sel)
      1'b0: y = a;
      1'b1: y = b;
    endcase
    end
endmodule

Behavioral description using if-else

module mux2to1_if 
(
    input a, b, sel, 
    output logic  y
);
    always_comb
    if (sel)
      y = b;
    else
      y = a;
    end
endmodule

The multiplexer selects between a and b based on the value of sel
We can write the Boolean expression
y = (a & ~sel) | (b & sel)
This is a minimized SOP (Sum of Products) form, which can easily be derived using the K-map

module mux2to1_logic 
(
    input  a, b, sel, 
    output         y
);
    assign y = (a & ~sel) | (b & sel);
endmodule

*/


