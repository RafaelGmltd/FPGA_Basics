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
output logic  [DIGIT-1:0] digit
);

//assign abcdefgh         = '0;
//assign led              = '0;
//assign digit            = '0;

wire enable;
wire [1:0] fsm_in;
wire mealy_fsm_out;

strobe_gen
#(.CLK_MHZ(CLK), .STRB_HZ(3))
sub_strobe_gen
(.strobe(enable), .*);

shift_reg
#(.D(LED))
sub_shift_reg
(
 .en         (enable),
 .shft_in    (   key),
 .shft_out   (fsm_in),
 .shft_reg   (   led),
 .*
 );
 
  
  mealy_fsm sub_mealy_fsm
 (
    .en        (       enable),
  .in_mealy  (       fsm_in),
  .out_mealy (mealy_fsm_out),
  .*
);
  
always_comb
begin
case(mealy_fsm_out)
  1'b0: abcdefgh = 8'b0000_0000;
  1'b1: abcdefgh = 8'b0011_1010;
endcase 
digit = DIGIT'(1);
end  
endmodule 