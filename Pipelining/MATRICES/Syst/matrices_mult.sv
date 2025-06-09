module matrices_mult
#(
  parameter WEIGHT_W    = 8,
  parameter X_DATA_W    = 8,
  parameter NUM_MACS    = 3 // number of multiply-accumulate
)
(
  input  logic i_clk,
  input  logic i_rst,

  input  logic [X_DATA_W -1:0] x1,
  input  logic [X_DATA_W -1:0] x2,
  input  logic [X_DATA_W -1:0] x3,
  
  output logic [(WEIGHT_W + X_DATA_W + NUM_MACS) -1:0] y1,
  output logic [(WEIGHT_W + X_DATA_W + NUM_MACS) -1:0] y2,
  output logic [(WEIGHT_W + X_DATA_W + NUM_MACS) -1:0] y3,

);

//WEIGHTS
  localparam W11 = 8'd1;
  localparam W12 = 8'd4;
  localparam W13 = 8'd7;
  
  localparam W21 = 8'd2;
  localparam W22 = 8'd5;
  localparam W23 = 8'd8;
  
  localparam W31 = 8'd3;
  localparam W32 = 8'd6;
  localparam W33 = 8'd9;  
  
//PIPELINS
  logic [X_DATA_W -1:0]  x11_pipe;
  logic [X_DATA_W -1:0]  x12_pipe;
  logic [X_DATA_W -1:0]  x13_pipe;
  
  logic [X_DATA_W -1:0]  x21_pipe;
  logic [X_DATA_W -1:0]  x22_pipe;
  logic [X_DATA_W -1:0]  x23_pipe;

//
  logic [X_DATA_W + X_DATA_W    :0] psumm11;
  logic [X_DATA_W + X_DATA_W +1 :0] psumm12;
  logic [X_DATA_W + X_DATA_W +2 :0] psumm13;
  
  logic [X_DATA_W + X_DATA_W    :0] psumm21;
  logic [X_DATA_W + X_DATA_W +1 :0] psumm22;
  logic [X_DATA_W + X_DATA_W +2 :0] psumm23;
  
  logic [X_DATA_W + X_DATA_W    :0] psumm31;
  logic [X_DATA_W + X_DATA_W +1 :0] psumm32;
  logic [X_DATA_W + X_DATA_W +2 :0] psumm33;
  
 
  
 /*
                      |                        |                        |
                      |                        |                        |
                      |                        |                        |
                      x1                       x2                       x3
                 ___________              ___________              ___________
                |           |  psumm11   |           | psumm12    |           |  psumm13
   '0 ------->  |  node11   | -------->  |  node12   | -------->  |  node13   |  -------->
                |___________|            |___________|            |___________|
                      |                        |                        |
                      |                        |                        |
                      |                        |                        |
                   x11_pipe                 x12_pipe                 x13_pipe
                 ___________              ___________              ___________
                |           |  psumm21   |           | psumm22    |           |  psumm23
   '0 ------->  |  node21   | -------->  |  node22   | -------->  |  node23   |  -------->
                |___________|            |___________|            |___________|
                      |                        |                        |
                      |                        |                        |
                      |                        |                        |
                   x21_pipe                 x22_pipe                 x23_pipe
                 ___________              ___________              ___________
                |           |  psumm11   |           | psumm12    |           |  psumm33
   '0 ------->  |  node31   | -------->  |  node32   | -------->  |  node33   |  -------->
                |___________|            |___________|            |___________|
 */
 
//NODE 11
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (1  ),
  .NEXT_SUM_W (17 )
) 
node_11 
(
  .i_clk    (i_clk   ),
  .i_rst    (i_rst   ),
  .i_weight (W11     ),
  .i_x_data (x1      ),
  .i_psumm  ('0      ),
  .o_nsumm  (psumm11 ),
  .o_x_data (x11_pipe )
);

//NODE 12
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (17 ),
  .NEXT_SUM_W (18 )
) 
node_12 
(
  .i_clk    (i_clk   ),
  .i_rst    (i_rst   ),
  .i_weight (W12     ),
  .i_x_data (x2      ),
  .i_psumm  (psumm11 ),
  .o_nsumm  (psumm12 ),
  .o_x_data (x12_pipe )
);

//NODE 13  
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (17 ),
  .NEXT_SUM_W (18 )
) 
node_13 
(
  .i_clk    (i_clk    ),
  .i_rst    (i_rst    ),
  .i_weight (W13      ),
  .i_x_data (x3        ),
  .i_psumm  (psumm12  ),
  .o_nsumm  (psumm13  ),
  .o_x_data (x13_pipe )
);

//NODE 21
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (1 ),
  .NEXT_SUM_W (17 )
) 
node_21 
(
  .i_clk    (i_clk    ),
  .i_rst    (i_rst    ),
  .i_weight (W21      ),
  .i_x_data (x11_pipe ),
  .i_psumm  ('0       ),
  .o_nsumm  (psumm21  ),
  .o_x_data (x21_pipe )
);

//NODE 22
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (17 ),
  .NEXT_SUM_W (18 )
) 
node_22 
(
  .i_clk    (i_clk    ),
  .i_rst    (i_rst    ),
  .i_weight (W22      ),
  .i_x_data (x12_pipe ),
  .i_psumm  (psumm21  ),
  .o_nsumm  (psumm22  ),
  .o_x_data (x22_pipe )
);

//NODE 23
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (18 ),
  .NEXT_SUM_W (19 )
) 
node_23 
(
  .i_clk    (i_clk    ),
  .i_rst    (i_rst    ),
  .i_weight (W23      ),
  .i_x_data (x13_pipe ),
  .i_psumm  (psumm22  ),
  .o_nsumm  (psumm23  ),
  .o_x_data (x23_pipe )
);

//NODE 31
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (1 ),
  .NEXT_SUM_W (17 )
) 
node_31 
(
  .i_clk    (i_clk    ),
  .i_rst    (i_rst    ),
  .i_weight (W31      ),
  .i_x_data (x21_pipe ),
  .i_psumm  ('0       ),
  .o_nsumm  (psumm31  ),
  .o_x_data (         )
);

//NODE 32
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (17 ),
  .NEXT_SUM_W (18 )
) 
node_32 
(
  .i_clk    (i_clk    ),
  .i_rst    (i_rst    ),
  .i_weight (W32      ),
  .i_x_data (x22_pipe ),
  .i_psumm  (psumm31  ),
  .o_nsumm  (psumm32  ),
  .o_x_data (         )
);

//NODE 33
node 
#(
  .WEIGHT_W   (8  ),
  .X_DATA_W   (8  ),
  .PREV_SUM_W (18 ),
  .NEXT_SUM_W (19 )
) 
node_33 
(
  .i_clk    (i_clk    ),
  .i_rst    (i_rst    ),
  .i_weight (W33      ),
  .i_x_data (x23_pipe ),
  .i_psumm  (psumm32  ),
  .o_nsumm  (psumm33  ),
  .o_x_data (         ),
  .valid    (valid_3  )
);

assign y1 = psumm13;
assign y2 = psumm23;
assign y3 = psumm33;

endmodule

