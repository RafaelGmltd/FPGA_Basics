module bin_cntr 
#(
    parameter  CLK_mhz = 50,
               LED     =  8
) 
(
    input clk,
    input rst,
    output logic [LED -1:0] led

);

    localparam CNT = $clog2 (CLK_mhz * 1000 *1000);
    logic [CNT-1:0] cnt;

    always_ff @(posedge clk or posedge rst) 
    begin
    if(rst)
      cnt = '0;
    else 
      cnt = cnt + 1'b1;   
    end

    assign led = cnt[$left(cnt)-:LED];
    
endmodule