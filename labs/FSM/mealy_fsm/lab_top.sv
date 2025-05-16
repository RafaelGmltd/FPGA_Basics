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

wire       toggle;
wire       enable;
wire [1:0] fsm_in;
wire [1:0] mealy_fsm_out;
wire [1:0] mealy_state_out;
// wire [2:0] moore_state_out;
// wire [1:0] moore_fsm_out;

strobe_gen
#(.CLK_MHZ(CLK), .STRB_HZ(3))
sub_strobe_gen
( .strobe(enable), .*);

shift_reg
#(.D(LED))
sub_shift_reg
(
 .en       (enable),
 .shft_in  (   key),
 .shft_out (fsm_in),
 .shft_reg (   led),
 .*
 );
 
//  moore_fsm sub_moore_fsm
//  (.en          (       enable),
//   .in_moore    (       fsm_in),
//   .out_moore   (moore_fsm_out),
//   .state_moore (moore_state_out),
//   .*
//   );
  
mealy_fsm sub_mealy_fsm
(.en        (         enable),
.in_mealy   (         fsm_in),
.out_mealy  (  mealy_fsm_out),
.state_mealy(mealy_state_out),
.*
);
  
digit sub_digit
(.toggle_digit(toggle),
 .clk(clk)
);
  

logic [7    :0]            abcdefgh_fsm_out, abcdefgh_state;
always_comb 
begin
if (toggle) 
begin
  abcdefgh               = abcdefgh_fsm_out; // digit 0
  digit                  = 4'b0001;        // on
end 
else begin
  abcdefgh               = abcdefgh_state; // digit 1
  digit                  = 4'b0010;          // on
end
end

//Mealy FSM
always_comb begin
//out
case (mealy_fsm_out)
  1'b0: abcdefgh_fsm_out      = 8'b1111_1100;
  1'b1: abcdefgh_fsm_out      = 8'b0110_0000;
  default: abcdefgh_fsm_out   = 8'b0000_0000;
endcase
//state
case (mealy_state_out)
  2'b00:   abcdefgh_state     = 8'b1111_1101;
  2'b01:   abcdefgh_state     = 8'b0110_0001;
  2'b10:   abcdefgh_state     = 8'b1101_1011;
  2'b11:   abcdefgh_state     = 8'b1111_0011;
  default: abcdefgh_state     = 8'b0000_0000;
endcase
end

// //Moore FSM
// always_comb begin
// //out
// case (moore_fsm_out)
//   2'd0:   abcdefgh_fsm_out     = 8'b1111_1100;
//   2'd2:   abcdefgh_fsm_out     = 8'b1101_1010;
//   2'd3:   abcdefgh_fsm_out     = 8'b1111_0010;
//   endcase
// //state
// case (moore_state_out)
//   3'b000: abcdefgh_state       = 8'b1111_1101;
//   3'b001: abcdefgh_state       = 8'b0110_0001;
//   3'b010: abcdefgh_state       = 8'b1101_1011;
//   3'b011: abcdefgh_state       = 8'b1111_0011;
//   3'b100: abcdefgh_state       = 8'b0110_0111;
//   default:abcdefgh_state       = 8'b0000_0000;
// endcase
// end

endmodule 