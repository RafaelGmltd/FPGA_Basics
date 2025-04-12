module lab_top
#(
  parameter CLK       = 100,
            KEY       = 2,
            SW        = 16,
            LED       = 16,
            DIGIT     = 4
)
(
input                    clk,                       
input                    rst,

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

//- - - - - FIFO Gen - - - - - - - 
localparam fifo_width = 4,
           fifo_depth = 4;
wire [fifo_width - 1:0] wr_data;
wire [fifo_width - 1:0] rd_data;
wire                    empty,full;
wire                    push = ~full &  key[0];
wire                    pop = ~empty &  key[1];
wire [3:0]              wr_ptr_display,
                        rd_ptr_display;

wire [fifo_width -1:0] write_data_const [0:2 ** fifo_width - 1] =
'{ 4'h0, 4'h1, 4'h2, 4'h3,
   4'h4, 4'h5, 4'h6, 4'h7,
   4'h8, 4'h9, 4'ha, 4'hb,
   4'hc, 4'hd, 4'he, 4'hf };

wire [fifo_width -1:0] write_data_index;
assign wr_data = write_data_const [write_data_index];
assign led[0] = full;
assign led[1] = empty;

counter 
#(fifo_width)
sub_counter
(
 .clk(slow_clk),
 .enable(push),
 .cntr(write_data_index),
 .* 
);

sync_fifo 
//sync_fifo_pow2 
//sync_fifo_optimized
#(.WIDTH(fifo_width),.DEPTH(fifo_depth))
sub_fifo
(
.clk(slow_clk),
.*
);

seven_segment_digit 
sub_seven_display
(
.number_0(rd_data),
.number_1(rd_ptr_display),
.number_2(wr_ptr_display),
.number_3(wr_data),
.segments(abcdefgh),
.digit_select(digit),
.*
);

//- - - - - Slow Clock Gen - - - - - - - 
wire slow_clk_raw;
slow_clk_gen 
#(26) 
sub_slow_clk_gen 
(.slow_clk_raw (slow_clk_raw), .*);

BUFG bufg_inst 
(
.I(slow_clk_raw),           // Input signal
.O(slow_clk    )           // Buff clock
);

endmodule