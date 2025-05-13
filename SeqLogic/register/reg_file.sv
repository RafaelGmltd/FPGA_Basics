module reg_file 
#(
  parameter           W = 8, //width
                      D = 2  //depth
)
(
input                 clk,
input                 wr_en,
input        [D-1 :0] wr_addr, 
                      rd_addr, // write addres, read addres if we want read or write data inside the reg file
input        [W-1 :0] wr_data, // data which we want write ibside the reg file
output logic [W-1 :0] rd_data  // data which we want read from the reg file
);
    
logic [W-1:0] array_reg [2**D-1:0];  // memory block

always @(posedge clk)                //write operation
begin 
if(wr_en)
  array_reg [wr_addr] <= wr_data;
end

assign rd_data = array_reg[rd_addr]; //read operation 

endmodule