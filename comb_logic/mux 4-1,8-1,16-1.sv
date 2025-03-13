// Using Instances of Smaller Multiplexers 2-to-1

module mux2to1
(
    input a, b, sel,
    output        y
);
 
 assign y = sel ? b : a;

endmodule

module mux4to1
(
    input A, B, C, D,
    input [1:0]  SEL,
    output         Y
);

    logic [1:0] inter;
 
    mux2to1 frst (.a(A), .b(B), .sel(SEL[0]), .y(inter[0]));
    mux2to1 scnd (.a(C), .b(D), .sel(SEL[0]), .y(inter[1]));
    mux2to1 thrd (.a(inter[0]), .b(inter[1]), .sel(SEL[1]), .y(Y));     

endmodule

/*
Direct 4-to-1 Multiplexer

module mux4to1
(
    input A, B, C, D,
    input [1:0]   SEL,
    output          Y
);

    assign Y = (SEL == 2'b00) ? A :
               (SEL == 2'b01) ? B :
               (SEL == 2'b10) ? C :
                                   D;  // Default case: SEL == 2'b11

endmodule

Based on the 4-to-1 multiplexer, we can implement an 8-to-1 multiplexer by 
cascading two 4-to-1 multiplexers and one 2-to-1 multiplexer


module mux2to1
(
    input a, b, sel,
    output y
);
 
    assign y = sel ? b : a;

endmodule

module mux4to1
(
    input A, B, C, D,
    input [1:0]   SEL,
    output          Y
);

    assign Y = (SEL == 2'b00) ? A :
               (SEL == 2'b01) ? B :
               (SEL == 2'b10) ? C :
                                   D;  // Default case: SEL == 2'b1    

endmodule

// 8-to-1 multiplexer using two 4-to-1 multiplexers and one 2-to-1 multiplexer
module mux8to1
(
    input A, B, C, D, E, F, G, H,
    input [2:0]              SEL,
    output                     Y
);

    logic [1:0] inter;
 
    // First 4-to-1 multiplexer
    mux4to1 mux_4_1_0 (.A(A), .B(B), .C(C), .D(D), .SEL(SEL[1:0]), .Y(inter[0]));
    
    // Second 4-to-1 multiplexer
    mux4to1 mux_4_1_1 (.A(E), .B(F), .C(G), .D(H), .SEL(SEL[1:0]), .Y(inter[1]));

    // Final 2-to-1 multiplexer to select between the outputs of the two 4-to-1 multiplexers
    mux2to1 mux_2_1 (.a(inter[0]), .b(inter[0]), .sel(SEL[2]), .y(Y)); 

endmodule

Or direct 8-to-1 Multiplexer


module mux8to1
(
    input A, B, C, D, E, F, G, H,
    input [2:0]              SEL,
    output                     Y
);

    // Using ternary operators to select between the 8 inputs based on SEL
    assign Y =  (SEL == 3'b000) ? A :
                (SEL == 3'b001) ? B :
                (SEL == 3'b010) ? C :
                (SEL == 3'b011) ? D :
                (SEL == 3'b100) ? E :
                (SEL == 3'b101) ? F :
                (SEL == 3'b110) ? G :
                                     H; // Default case: SEL == 3'b111, select H

endmodule

In the same way, using a cascade of 4-to-1 or 8-to-1 multiplexers, you can build a 16-to-1 multiplexer, and so on.

Each stage of multiplexers can combine multiple lower-order multiplexers to progressively select 
from more inputs. For example, a 16-to-1 multiplexer can be constructed by using two 8-to-1 multiplexers 
and one 4-to-1 multiplexer at the final stage.


