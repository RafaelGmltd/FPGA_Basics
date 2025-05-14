module fifo_opt
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
output                     full,
output                     empty   
);

localparam  pointer_width = $clog2 (DEPTH),
            counter_width = $clog2 (DEPTH +1);
localparam [counter_width -1:0] max_ptr = counter_width'(DEPTH -1); // 4'(9) = 1001 max flag when DEPTH = 10

logic [pointer_width -1:0] wr_ptr,rd_ptr;
logic rd_odd_circle, wr_odd_circle;
logic [WIDTH-1:0] mem [DEPTH -1:0];

always_ff@(posedge clk or posedge rst)
begin
if(rst)
begin
  wr_ptr        <= '0;
  wr_odd_circle <= '0;
end
else if (push)
begin
  if(wr_ptr == max_ptr)
  begin
    wr_ptr        <= '0 ;
    wr_odd_circle <= ~wr_odd_circle;
  end
  else
    wr_ptr          <= wr_ptr + 1'b1;
end
end
    
always_ff@(posedge clk or posedge rst)
begin
if(rst)
begin
  rd_ptr        <= '0;
  rd_odd_circle <= '0;
end
else if (pop)
begin
  if (rd_ptr == max_ptr)
  begin
    rd_ptr        <= '0;
    rd_odd_circle <= ~rd_odd_circle;
  end
  else
  begin
    rd_ptr          <= rd_ptr +1'b1;
  end
    rd_data         <= mem[rd_ptr];
end
end

always_ff@(posedge clk)
begin
  if(push)
    mem[wr_ptr]   <= wr_data;
end
 
assign same_ptr      = (rd_ptr == wr_ptr);
assign same_circle   = (wr_odd_circle == rd_odd_circle);

assign full          = same_ptr & ~same_circle;
assign empty         = same_ptr &  same_circle;
             
endmodule