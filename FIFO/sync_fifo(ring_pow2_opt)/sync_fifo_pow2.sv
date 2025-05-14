module sync_fifo_pow2
#(
  parameter WIDTH = 4 ,
            DEPTH = 4
)
(
input                      clk,
input                      rst,
input                      push,
input                      pop,
input        [WIDTH - 1:0] wr_data,
output logic [WIDTH - 1:0] rd_data,
output       [WIDTH    :0] rd_ptr_display,wr_ptr_display,
output                     full,
output                     empty   
);

localparam  pointer_width = $clog2 (DEPTH),
            extended_pointer_width = pointer_width + 1;


logic [extended_pointer_width - 1:0] ext_wr_ptr, ext_rd_ptr;
wire  [pointer_width - 1:0] wr_ptr = ext_wr_ptr [pointer_width - 1:0];// LSB
wire  [pointer_width - 1:0] rd_ptr = ext_rd_ptr [pointer_width - 1:0];
logic [WIDTH-1:0] mem [DEPTH -1:0];

always_ff@(posedge clk or posedge rst)
begin
  if(rst)
    ext_wr_ptr       <= '0;
  else if (push)
  begin
    ext_wr_ptr       <= ext_wr_ptr + 1'b1;
    mem [wr_ptr]     <= wr_data;
  end
end

always_ff@(posedge clk or posedge rst)
begin
  if(rst)
    ext_rd_ptr       <= '0;
  else if (pop)
  begin
    ext_rd_ptr       <= ext_rd_ptr + 1'b1;
    rd_data          <= mem [rd_ptr];
  end
end

assign empty   =  (ext_rd_ptr == ext_wr_ptr);
assign full    = ({~ext_wr_ptr[ pointer_width],ext_wr_ptr[ pointer_width-1:0]} == ext_rd_ptr);// {~MSB,LSB} == {MSB,LSB}
//assign rd_data = mem [rd_ptr];
assign rd_ptr_display = ext_rd_ptr;
assign wr_ptr_display = ext_wr_ptr;