module fifo_valid_ready
#(
  parameter WIDTH       = 7,
            DEPTH       = 8
)
(
input                 clk,
input                 rst,
  
 //- - - - - UPSTREAM - - - - - - - 
input                 up_valid,
output                up_ready,
input [WIDTH -1:0]    wr_data,

 //- - - - - DOWNSTREAM - - - - - - - 
input                 down_ready,
output                down_valid,
output [WIDTH -1:0]   rd_data
);

wire fifo_push;
wire fifo_pop;
wire fifo_empty;
wire fifo_full;

assign up_ready          = ~fifo_full;
assign fifo_push         = up_ready & up_valid;

assign down_valid        = ~fifo_empty;
assign fifo_pop          = down_valid & down_ready;

fifo_opt
#(.WIDTH(WIDTH), .DEPTH(DEPTH))
sub_sync_opt
(
.clk   (clk),
.rst   (rst),
.push  (fifo_push),
.pop   (fifo_pop),
.empty (fifo_empty),
.full  (fifo_full),
.*
);

always_ff@(posedge clk)
begin
  $display("Time: %0t |fifo_empty: %0d   |fifo_full: %0d", 
  $time, fifo_empty, fifo_full);
  $display("_____________________");
end
endmodule