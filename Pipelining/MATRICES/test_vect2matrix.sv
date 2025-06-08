module test;

  parameter  WIDTH     = 8;
  parameter  ROW_A     = 3;
  parameter  COL_A     = 3;
  parameter  ROW_B     = COL_A;
  parameter  COL_B     = 3;

  logic                                i_clk;
  logic                                i_rst;
  logic                                i_valid;
  logic [(WIDTH * ROW_A * COL_A)-1:0]  i_a_vect;
  logic [(WIDTH * ROW_B * COL_B)-1:0]  i_b_vect;
  logic                                o_valid;
  logic [WIDTH-1:0]                    o_a_mat [ROW_A-1:0][COL_A-1:0];
  logic [WIDTH-1:0]                    o_b_mat [ROW_B-1:0][COL_B-1:0];

  vector2matrix
  #(
    .WIDTH (WIDTH ),
    .ROW_A (ROW_A ),
    .COL_A (COL_A ),
    .ROW_B (ROW_B ),
    .COL_B (COL_B )
  )
  dut
  (
    .i_clk    (i_clk    ),
    .i_rst    (i_rst    ),
    .i_valid  (i_valid  ),
    .i_a_vect (i_a_vect ),
    .i_b_vect (i_b_vect ),
    .o_valid  (o_valid  ),
    .o_a_mat  (o_a_mat  ),
    .o_b_mat  (o_b_mat  )
  );

  parameter CLK_PERIOD = 10;


  initial begin
    i_clk = 0;
    forever #(CLK_PERIOD / 2) i_clk = ~i_clk;
  end


  initial begin
    i_rst = 1'b1;
    #(CLK_PERIOD);
    i_rst = 1'b0;
  end


  initial begin
    i_valid  = 0;
    i_a_vect = 0;
    i_b_vect = 0;

    wait (!i_rst);
    @(posedge i_clk);


    // A(3x3):
    // [ [1 2 3],
    //   [4 5 6],
    //   [7 8 9] ]
    i_a_vect = {
      8'd1, 8'd2, 8'd3,   // row 0
      8'd4, 8'd5, 8'd6,   // row 1
      8'd7, 8'd8, 8'd9    // row 2
    };

    // B(3x3):
    // [ [9 8 7],
    //   [6 5 4],
    //   [3 2 1] ]
    i_b_vect = {
      8'd9, 8'd8, 8'd7,   // row 0
      8'd6, 8'd5, 8'd4,   // row 1
      8'd3, 8'd2, 8'd1    // row 2
    };

    i_valid = 1;
    @(posedge i_clk);
    i_valid = 0;

    wait(o_valid);

    $display(" Matrix A:");
    foreach (o_a_mat[i, j])
      $display("A [%0d][%0d] = %0d", i, j, o_a_mat[i][j]);

    $display(" Matrix B:");
    foreach (o_b_mat[i, j])
      $display("B[%0d][%0d] = %0d", i, j, o_b_mat[i][j]);

    #(50);
    $finish();
  end

endmodule