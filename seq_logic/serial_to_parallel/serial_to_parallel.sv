module serial_parallel
#(
  parameter       W = 8
) 
(
 input                 clk,rst,
 input                 serial_data,
                       serial_valid,
 output logic          parallel_valid,
 output logic [W -1:0] parallel_data
);

logic [W      -1:0] data;
logic [$clog2(W):0] cnt;

always_ff @(posedge clk or posedge rst) 
  if(rst)
    begin
      data            <= '0;
      parallel_valid  <= '0;
      parallel_data   <= '0;
      cnt             <= '0;
    end
  else if (cnt != W)
    begin
    if( serial_valid )
    begin 
      data             <= {serial_data,data[W -1:1]};
      cnt              <= cnt + 1'b1; 
    end
    else
    begin
    data               <= data;
    cnt                <= cnt;
    end
    end
  else 
    begin   
    parallel_data      <= data;
    parallel_valid     <= 1'b1;
    cnt                <= '0;
    end
endmodule