module basys3_specific_top
#(
    parameter CLK       = 100,
              PIXEL_CLK = 25,
              KEY       = 2,
              SW        = 16,
              LED       = 16,
              DIGIT     = 4,
              
              WIDTH  = 640,
              HEIGHT = 480,

              RED         = 4,
              GREEN       = 4,
              BLUE        = 4,

              ORDINATE   = $clog2 ( WIDTH   ),
              ABSCISSA   = $clog2 ( HEIGHT  )
)
(
input                   clk,

input                   btnC,
                        btnU,
                        btnL,
                        btnR,
                        btnD,
                        
input  [SW   -1:0]      sw,
output [LED  -1:0]      led,
output [      6:0]      seg,
output                  dp,
output [DIGIT-1:0]      an,

output                  Hsync,
output                  Vsync,

output [RED      - 1:0] vgaRed,
output [GREEN    - 1:0] vgaGreen,
output [BLUE     - 1:0] vgaBlue
);

// - - - - - - - - - - - - - - - - - - - - - - - - - - -

localparam w_lab_sw         = SW - 1;
wire rst                    = sw[SW-1:0]; // rst = sw[15] 
wire [w_lab_sw-1:0]lab_sw   = sw[w_lab_sw-1:0];

// - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - - Seven-Seg-Display - - - - - - - - - - - -

wire   [        7:0]    abcdefgh;
wire   [        7:0]    digit;

assign {seg[0], seg[1], seg[2], seg[3],
        seg[4], seg[5], seg[6],dp } = ~abcdefgh;
assign an = ~digit;

// - - - - - - Graphics - - - - - - - - - - - -  

wire                 display_on;

wire [ORDINATE     - 1:0] x;
wire [ABSCISSA     - 1:0] y;

wire [RED        - 1:0] red;
wire [GREEN    - 1:0] green;
wire [BLUE      - 1:0] blue;

assign vgaRed   = display_on ? red   : '0;
assign vgaGreen = display_on ? green : '0;
assign vgaBlue  = display_on ? blue  : '0;

// - - - - - - - - - - - - - - - - - - - - - - - - - - -

lab_top
#(
    .CLK           (CLK             ),
    .PIXEL_CLK     (PIXEL_CLK       ),
    .KEY           (KEY             ),
    .SW            (w_lab_sw        ),
    .LED           (LED             ),
    .DIGIT         (DIGIT           ),
    
    .WIDTH         ( WIDTH          ),
    .HEIGHT        ( HEIGHT         ),

    .RED           ( RED            ),
    .GREEN         ( GREEN          ),
    .BLUE          ( BLUE           )
)
sub_lab_top
(
    .clk           ( clk            ),
    .rst           ( rst            ),

    .key           ( { btnD, btnU, btnL ,btnC, btnR } ),
    .sw            ( lab_sw         ),

    .led           ( led            ),

    .abcdefgh      ( abcdefgh       ),
    .digit         ( digit          ),
    .x             ( x              ),
    .y             ( y              ),

    .red           ( red            ),
    .green         ( green          ),
    .blue          ( blue           )
);

wire [9:0] x10; assign x = x10;
wire [9:0] y10; assign y = y10;

vga
# (
   .CLK_MHZ        ( CLK      ),
   .PIXEL_MHZ      ( PIXEL_CLK)
)
vga_sub
(
  .clk             ( clk         ),
  .rst             ( rst         ),
  .vsync           ( Vsync       ),
  .hsync           ( Hsync       ),
  .display_on      ( display_on  ),
  .hpos            ( x10         ),
  .vpos            ( y10         ),
  .pixel_clk       (             )
);


endmodule
