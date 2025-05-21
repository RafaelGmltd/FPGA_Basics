module uart_tx(
input        rst_i,
input        clk_i,
input        tick_i,
input        data_ready_i, // new data is ready at the input
input [7 :0] data_i,       // data input
output       ready_rcv_o,  // ready to receive new data when all the old ones previously received have been sent to the receiver
output       txd_o         // one bit to the output
);
    
localparam [0 :0] ST_IDLE = 1'b0;
localparam [0 :0] ST_TX   = 1'b1;
    
reg [7 :0] tx_data;       // array data bit
reg        tx_data_exist; // flag that there is data to transmit
reg [9 :0] tx_buf;        // vector with all bits: start, data, and stop
reg [3 :0] tx_buf_cnt;    // counter of transmitted bits (from 0 to 9)
reg [3 :0] tick_cnt;      // tick counter (from 0 to 15)
reg        state; 
        
assign ready_rcv_o = !(data_ready_i | tx_data_exist); // ready to receive if there is no data to transmit, that is, everything has been sent already
assign txd_o       = tx_buf[0];                       // one bit to the output, right side shift register
    
always@(posedge clk_i)
begin
if (rst_i)
  begin
    tx_data_exist <= 1'b0;
    state         <= ST_IDLE;
  end
else
  begin
  case(state)
  ST_IDLE:
    begin
        tick_cnt   <= 4'd0;
        tx_buf_cnt <= 4'd0;
        tx_buf     <= (tick_i & tx_data_exist) ? {1'b1, tx_data, 1'b0}: {10{1'b1}}; // if there is data to transmit and tick is on, write to bit array
                                                                                    // here it's the opposite: first stop bit, then data bits and start bit
                                                                                    // because at the output the first is bit [0],
                                                                                    // otherwise fill the whole vector with 11_1111_1111 because if zero,
                                                                                    // the receiver can mistakenly take 0 as a start bit and start collecting incorrect data
        state      <= (tick_i & tx_data_exist) ? ST_TX : ST_IDLE;                   
        if (data_ready_i)                                                           // signal — data at the input
            begin
              tx_data       <= data_i;                                              // write 8 data bits into data bit 
              tx_data_exist <= 1'b1;                                                // flag that data is ready to transmit, go to the next state
            end
    end
  
  ST_TX:
    begin   
        state <= (tx_buf_cnt == 4'd10)? ST_IDLE : ST_TX;                            // when all 10 bits are transmitted, go back to initial state
        if (tick_i)
            begin
              tick_cnt <= tick_cnt + 4'd1;                                      
			  if (tick_cnt == 4'd15)
                begin
                  tx_buf_cnt <= tx_buf_cnt + 4'd1;                                  // after 15 ticks, means first of 10 bits is transmitted
                  tx_buf     <= {1'b1, tx_buf[9 :1]};                               // bit [0] goes to output, right side  shift register
                end
            end
        if (tx_buf_cnt == 4'd10)                                                    // bit transmission counter: if equal to 10, all bits are transmitted
            begin 
              tx_data_exist <= 1'b0;                                                // no data to transmit, all processed
            end
    end    
                            
  endcase
  end
end
    
endmodule 