module lab_top
#(
    parameter CLK       = 100,
              KEY       = 2,
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
output logic [DIGIT-1:0] digit
);

//assign abcdefgh         = '0;
//assign led              = '0;
//assign digit            = '0;

localparam sw_actual = (sw > 8) ? 8 : sw;

logic [sw_actual-1:0] pow_input;
logic [(5*sw_actual)-1:0] pow5;
logic [(5*sw_actual)-1:0] pow_output;


always_ff @ (posedge clk or posedge rst)
begin
if (rst)
  pow_input <= '0;
else
  pow_input <= sw;
end

assign pow5 = pow_input * pow_input * pow_input * pow_input * pow_input;

always_ff @ (posedge clk or posedge rst)
begin
if (rst)
  pow_output <= '0;
else
  pow_output <= pow5;

assign led = LED'(pow_output);
end

endmodule