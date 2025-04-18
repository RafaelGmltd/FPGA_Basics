module test_ser_par;

  parameter W = 8;

  logic clk = 0;
  logic rst;
  logic serial_data;
  logic serial_valid;
  logic parallel_valid;
  logic [W-1:0] parallel_data;

  // DUT
  serial_parallel #(.W(W)) dut (
    .clk(clk),
    .rst(rst),
    .serial_data(serial_data),
    .serial_valid(serial_valid),
    .parallel_valid(parallel_valid),
    .parallel_data(parallel_data)
  );

  // Clock generator: 10ns period
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    $display("Start simulation");
    rst = 1;
    serial_valid = 0;
    serial_data = 0;

    repeat(2) @(posedge clk); 

    rst = 0;


    serial_valid = 1;
    serial_data = 1; @(posedge clk); // bit 0
    serial_data = 1; @(posedge clk); // bit 1
    serial_data = 1; @(posedge clk); // bit 2
    serial_data = 1; @(posedge clk); // bit 3
    serial_data = 1; @(posedge clk); // bit 4


    serial_valid = 0;
    serial_data = 1; @(posedge clk); // пауза


    serial_valid = 1;
    serial_data = 1; @(posedge clk); // bit 5
    serial_data = 1; @(posedge clk); // bit 6
    serial_data = 1; @(posedge clk); // bit 7


    serial_valid = 0;
    serial_data = 0; @(posedge clk);


    $display("parallel_valid = %b, parallel_data = %b", parallel_valid, parallel_data);


    repeat(3) @(posedge clk);
    $finish;
  end

endmodule