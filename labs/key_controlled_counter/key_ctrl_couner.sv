module key_ctrl_cntr 
 
(
    input              clk,
    input              rst,
    input        [1:0] key,
    output logic [7:0] led,
    output logic en_up,
    output logic en_down
);
    
    wire any_key_0 =  key[0];  // reduction operation logical OR: if at least one 
                            // of the buttons is pressed, then any_key is equal to 1
    wire any_key_1 = key[1];

    logic  any_key_r_0;
    logic  any_key_r_1;   // registers

    always_ff @ (posedge clk or posedge rst)
        if (rst)
          any_key_r_0 <= '0;
        else
          any_key_r_0 <= any_key_0;
          
     always_ff @ (posedge clk or posedge rst)
        if (rst)
          any_key_r_1 <= '0;
        else
          any_key_r_1 <= any_key_1;  

    wire any_key_pressed_up =  any_key_0 & ~any_key_r_0;
    wire any_key_pressed_down =  ~any_key_1 & any_key_r_1;
    

    logic [7:0] cnt;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
          cnt <= '0;
        else if (any_key_pressed_up)
          cnt <= cnt + 1'd1;
        else if (any_key_pressed_down)
          cnt <= cnt - 1'd1;


    assign en_up = any_key_pressed_up;
    assign en_down = any_key_pressed_down;
    assign led = (cnt);

    
endmodule