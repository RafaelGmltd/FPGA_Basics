`timescale 1ns/1ps

module key_ctrl_cntr_tb;

  logic       clk;
  logic       rst;
  logic [1:0] key;
  logic [7:0] led;
  logic     en_up;
  logic   en_down;

  key_ctrl_cntr uut (
      .clk(clk),
      .rst(rst),
      .key(key),
      .led(led),
      .en_up(en_up),
      .en_down(en_down)
  );

  // Clock signal generator (50 MHz -> 20 ns period)
  always #10 clk = ~clk;

  initial begin

    clk = 0;
    rst = 1;
    key = 2'b00;
    #10;  

    rst = 0;
    #10;  

    // Increment up to 4
    repeat (4) begin
      key[0] = 1;  // Press key[0]
    #30;
      key[0] = 0;  // Release
    #30;
    end
    
    #10;
    
    //Decrement down to 0
    repeat (4) begin
      key[1] = 1;  // Press key[1]
    #30;
      key[1] = 0;   // Release
    #30;
    end

    #100;
    $stop;
  end




endmodule