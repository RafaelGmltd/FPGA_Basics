module sync_fifo
#(
  parameter WIDTH =  8,
            DEPTH =  10
)
(
input                      clk,
input                      rst,
input                      push,
input                      pop,
input        [WIDTH - 1:0] wr_data,
output logic [WIDTH - 1:0] rd_data,
output       [WIDTH - 1:0] rd_ptr_display,wr_ptr_display,
output                     full,
output                     empty   
);

localparam  pointer_width = $clog2 (DEPTH),
            counter_width = $clog2 (DEPTH +1);
localparam [counter_width -1:0] max_ptr = counter_width'(DEPTH -1); // 4'(9) = 1001 max flag when DEPTH = 10

logic [pointer_width -1:0] wr_ptr,rd_ptr;
logic [counter_width -1:0] cntr;
logic [WIDTH-1:0] mem [DEPTH -1:0];

// Almost FULL/Empty
logic push_r, pop_r;
always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    push_r <= 1'b0;
    pop_r  <= 1'b0;
  end else begin
    push_r <= push;
    pop_r  <= pop;
  end
end

//Pointers
always_ff@(posedge clk or posedge rst)
    if(rst)
      wr_ptr       <= '0;
    else if (push)
    begin
      wr_ptr       <= wr_ptr == max_ptr ? '0 : wr_ptr + 1'b1;
      mem [wr_ptr] <= wr_data;
    end
always_ff@(posedge clk or posedge rst)
    if(rst)
      rd_ptr       <= '0;
    else if (pop)
    begin
      rd_ptr       <= rd_ptr == max_ptr ? '0 : rd_ptr + 1'b1;
      rd_data      <= mem[rd_ptr];
    end

// Counter
always_ff@(posedge clk or posedge rst)
    if(rst)
      cntr         <= '0;
    else if(push && ~pop )
      cntr         <= cntr + 1'b1;
    else if(pop && ~push )
      cntr         <= cntr -1'b1;
      
//assign empty   = (cntr ==    '0);
//assign full    = (cntr == DEPTH);
//assign rd_data = mem [rd_ptr];
assign full  = push_r ? (cntr >= DEPTH -1) : (cntr == DEPTH);
assign empty = pop_r  ? (cntr >= 1       ) : (cntr == 0    );
assign rd_ptr_display = rd_ptr;
assign wr_ptr_display = wr_ptr;
               
endmodule