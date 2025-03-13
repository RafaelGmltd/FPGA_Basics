module add_1
(
	input cin, a, b,		     // input ports
	output cout, sum	 		// output ports
);
	
	wire x_o_1, x_o_2, x_o_3;	// signals

	and x_1 (x_o_1,a,b);		// simple gate-level function blocks
	xor x_2 (x_o_2,a,b);
	and x_3 (x_o_3,a,b);
	xor x_4 (sum,cin, x_2);
	or x_5 (cout,x_3,x_1);
	
endmodule

	