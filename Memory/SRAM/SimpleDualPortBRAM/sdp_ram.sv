module sram_dualport 
#(
  parameter          WIDTH  = 8,
                     DEPTH  = 8,
                     ADDR_W = $clog2(DEPTH)    
)
(
input                      clk,
input                      wen,
input                      ren,
input        [ADDR_W -1:0] wr_addr,
input        [ADDR_W -1:0] rd_addr,
input        [WIDTH  -1:0] data_i,
output logic [WIDTH  -1:0] data_o,
output logic [WIDTH  -1:0] data_out_sram
);

logic [WIDTH -1:0] sram [DEPTH -1:0];
//assign data_out_sram = sram[1];
always @(posedge clk) 
begin
 if (wen)
 begin
   sram[wr_addr] <= data_i;
   end
end
always @(posedge clk) 
if (ren)
begin
  data_o         <= sram[rd_addr];
end
endmodule