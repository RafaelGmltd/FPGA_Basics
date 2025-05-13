module random(q)
    output[0:31] q;
    logic [0:31] d;

    initial
      r_seed = 2;
    always
    #10 q = $random(r_seed); 
    
endmodule