module lab_top
#(
    parameter CLK       = 100,
              KEY       = 5,
              SW        = 16,
              LED       = 16,
              DIGIT     = 4
)
(
input                   clk,                       
input                   rst,

//- - - - - Keys,Switches,LEDs - - - - - - - 

input        [KEY-1:0]   key,
input        [SW- 1:0]   sw,
output logic [LED-1:0]   led,

//- - - - - Seven Seg Display - - - - - - - 

output logic [      7:0] abcdefgh,
output wire  [DIGIT-1:0] digit
);

//assign abcdefgh         = '0;
//assign led              = '0;
//assign digit            = '0;


logic [31:0] cnt;

always_ff @(posedge clk or posedge rst) 
    if(rst)
      cnt <= '0;
    else
      cnt <= cnt + 1'b1;
localparam W               = 8;     
wire enable                = (cnt[25:0] == '0);
wire button_on             = |key;


logic [W-1:0] shift_reg;

always_ff @(posedge clk or posedge rst)
    if(rst)
      shift_reg <= '1 ;                             

    else if (enable & ~sw[1] & sw[2])
       shift_reg <= {shift_reg[W-2:0], button_on};  //left
    else if (enable & sw[1] & sw[2])
       shift_reg = {button_on,shift_reg[W-1:1]};    //right 
    else if (enable & ~sw[2])
       shift_reg = {shift_reg[0],shift_reg[W-1:1]}; //ring  

assign led = shift_reg;
    
endmodule