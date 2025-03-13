module add_w 
#(
	parameter W = 4
)
(
	input [W-1:0]      a, b,
	input               cin,
    output [W-1:0]      sum,
	output             cout
);
	
    assign {cout, sum} = a + b + cin;

endmodule 

