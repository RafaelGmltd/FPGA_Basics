module basys3_specific_top
#(
    parameter CLK       = 100,
              KEY       = 5,
              SW        = 16,
              LED       = 16,
              DIGIT     = 4
)
(
input                   clk,

// - - - - - - 5 buttons - - - - - - - - - - - -

input                   btnC,
                        btnU,
                        btnL,
                        btnR,
                        btnD,
                        
input  [SW   -1:0]      sw,
output [LED  -1:0]      led,
output [      6:0]      seg,
output                  dp,
output [DIGIT-1:0]      an
);

// - - - - - - - - - - - - - - - - - - - - - - - - - - -

localparam w_lab_sw         = SW - 1;
wire rst                    = sw[SW-1:0];
wire [w_lab_sw-1:0]lab_sw   = sw[w_lab_sw-1:0];

// - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - - Seven-Seg-Display - - - - - - - - - - - -

wire   [        7:0]    abcdefgh;
wire   [        7:0]    digit;

assign {seg[0], seg[1], seg[2], seg[3],
        seg[4], seg[5],seg[6],dp } = ~abcdefgh;
assign an = ~digit;

// - - - - - - - - - - - - - - - - - - - - - - - - - - -

lab_top
#(
    .CLK        (CLK          ),
    .KEY        (KEY          ),
    .SW         (w_lab_sw     ),
    .LED        (LED          ),
    .DIGIT      (DIGIT        )
)
sub_lab_top
(
    .clk         ( clk        ),
    .rst         ( rst        ),

    .key         ( { btnD, btnU, btnL ,btnC, btnR } ),
    .sw          ( lab_sw      ),

    .led         ( led         ),

    .abcdefgh    ( abcdefgh    ),
    .digit       ( digit       )
);



endmodule
