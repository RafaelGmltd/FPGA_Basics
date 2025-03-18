module shift_reg 
#(
    parameter LED = 8,
              KEY = 4 
) 
(
    input             rst, clk,
    input        [KEY-1:0] key,
    output logic [LED-1:0] led
);

logic [31:0] cnt;

always_ff @(posedge clk or posedge rst) 
    if(rst)
      cnt <= '0;
    else
      cnt <= cnt + 1'b1;
wire enable = (cnt[22:0] == '0);

wire button_on = |key;
logic [LED-1:0] shift_reg;

always_ff @(posedge clk or posedge rst)
    if(rst)
      //shift_reg <= '0 ;//normal
      shift_reg <= 3;//for ring
    else
       shift_reg = {shift_reg[0], shift_reg [7:1] }; //ring
       //shift_reg = {button_on,shift_reg[LED-1:1]}; //right
       //shift_reg = {shift_reg[N-2:0], button_on}; //left

assign led = shift_reg;

    
endmodule