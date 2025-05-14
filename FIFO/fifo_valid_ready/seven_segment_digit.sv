module seven_segment_digit (
input               clk,
input               rst,
input        [3:0]  number_0,
input        [3:0]  number_1,
input        [3:0]  number_2,
input        [3:0]  number_3,
output logic [7:0]  segments,
output logic [3:0]  digit_select
);

logic [15:0] cnt;

always_ff @ (posedge clk or posedge rst)
begin
  if (rst)
    cnt <= 16'd0;
  else
    cnt <= cnt + 16'd1;
end

logic [1:0] digit_index;

function [7:0] bcd_to_segments(input [3:0] bcd);
  case (bcd)
    4'h0: bcd_to_segments = 8'b11111100;
    4'h1: bcd_to_segments = 8'b01100000;
    4'h2: bcd_to_segments = 8'b11011010;
    4'h3: bcd_to_segments = 8'b11110010;
    4'h4: bcd_to_segments = 8'b01100110;
    4'h5: bcd_to_segments = 8'b10110110;
    4'h6: bcd_to_segments = 8'b10111110;
    4'h7: bcd_to_segments = 8'b11100000;
    4'h8: bcd_to_segments = 8'b11111110;
    4'h9: bcd_to_segments = 8'b11110110;
    4'ha: bcd_to_segments = 8'b11101110;
    4'hb: bcd_to_segments = 8'b00111110;
    4'hc: bcd_to_segments = 8'b10011100;
    4'hd: bcd_to_segments = 8'b01111010;
    4'he: bcd_to_segments = 8'b10011110;
    4'hf: bcd_to_segments = 8'b10001110;
    default: bcd_to_segments = 8'b00000000;
  endcase
endfunction

always_ff @(posedge clk or posedge rst) 
begin
  if (rst)
    digit_index <= 0;
  else if (cnt == 16'b0)
    digit_index <= digit_index + 1;
end

always_comb 
begin
  case (digit_index)
    2'd0: 
    begin
      digit_select = 4'b0001;
      segments     = bcd_to_segments(number_0);
    end
    2'd1: 
    begin
      digit_select = 4'b0010;
      segments     = bcd_to_segments(number_1);
    end
    2'd2: 
    begin
      digit_select = 4'b0100;
      segments     = bcd_to_segments(number_2);
    end
    2'd3: 
    begin
      digit_select = 4'b1000;
      segments     = bcd_to_segments(number_3);
    end
  endcase
end

endmodule
