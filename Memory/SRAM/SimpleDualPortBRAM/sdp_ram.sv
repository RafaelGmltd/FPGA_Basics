// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v
module simple_dual_one_clock
#(
  parameter          WIDTH  = 8,
                     DEPTH  = 8,
                     ADDR_W $clog2(DEPTH)    
)
(
input                clk,
input                wen_i,
input                ren_i,
input  [ADDR_W -1:0] waddr_i,
input  [ADDR_W -1:0] raddr_i,
input  [WIDTH  -1:0] data_i,
output [WIDTH  -1:0] data_o,
);

logic [WIDTH -1:0] sram [DEPTH -1:0];

always @(posedge clk) 
begin
 if (wen_i)
   sram[waddr_i] <= data_i;
end
always @(posedge clk) 
begin
 if (ren_i)
  data_o         <= sram[raddr_i];
end
endmodule