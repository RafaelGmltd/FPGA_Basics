module lab_top
#(
    parameter CLK       = 100,
              KEY       = 5,
              SW        = 16,
              LED       = 16,
              DIGIT     = 4
)
(
input                   clk,                       
input                   rst,

//- - - - - Keys,Switches,LEDs - - - - - - - 

input        [KEY-1:0]   key,
input        [SW- 1:0]   sw,
output logic [LED-1:0]   led,

//- - - - - Seven Seg Display - - - - - - - 

output logic [      7:0] abcdefgh,
output wire  [DIGIT-1:0] digit
);

//assign abcdefgh         = '0;
//assign led              = '0;
//assign digit            = '0;

localparam CNT = $clog2 (CLK * 1000 *1000);
logic [CNT-1:0] cnt;

always_ff @(posedge clk or posedge rst) 
begin
    if(rst)
      cnt <= '0;
    else 
      cnt <= cnt + 1'b1;   
end

    assign led = cnt[$left(cnt)-:4];
    

   
endmodule