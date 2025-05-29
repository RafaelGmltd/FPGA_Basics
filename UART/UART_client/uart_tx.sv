`default_nettype none
module uart_tx 
#(
  parameter OVERSAMPLE_RATE =          16,
  parameter NUM_BITS        =           8, // Within 5-9
  parameter PARITY_ON       =           1, // 0: Parity disabled. 1: Parity enabled.
  parameter PARITY_EO       =           1, // 0: Even parity. 1: Odd parity.
  parameter NUM_STOP_BITS   =           1  // Within 1-2
)
  (
  input wire                 clk_i,
  input wire                 rst_i,
  input wire                 tick_i,
  input wire                 fifo_empty_i,
  input wire  [NUM_BITS-1:0] fifo_rd_data_i,
  output wire                fifo_rd_en_o,
  output reg                 tx_o
  );
  
// Parity even/odd encoding
localparam EVEN_PAR = 0;
localparam ODD_PAR  = 1;

// TX byte register
logic [NUM_BITS-1:0] tx_byte, tx_byte_sreg;
  
// Byte index register
logic [$clog2(NUM_BITS)-1:0] idx;
  
// Stop bit counter
logic stop_b_cnt;

// Ticks counter
logic [$clog2(OVERSAMPLE_RATE)-1:0] ticks_cnt;  

// Control FSM
typedef enum logic [2 :0] 
{
    TX_IDLE, 
    TX_GET_DATA,
    TX_START, 
    TX_DATA, 
    TX_PARITY, 
    TX_STOP
}
state_t;
state_t state;
  
assign fifo_rd_en_o = (!fifo_empty_i) && state==TX_IDLE;;
  
always_ff @(posedge clk_i)
if (rst_i) 
begin
  tx_byte           <= '0;
  tx_byte_sreg      <= '0;
  idx               <= '0;
  tx_o              <= 1'b1;
  stop_b_cnt        <= 1'b0;
  state             <= TX_IDLE;
end 
else 
begin  
  case (state)
//-------------------------------------------------------------------------------------------------
    TX_IDLE: 
    begin      
      if (!fifo_empty_i) 
      begin
        state           <= TX_GET_DATA;
      end 
    end    
    TX_GET_DATA: 
    begin    
      tx_o         <= 1'b0;
      tx_byte      <= fifo_rd_data_i;
      tx_byte_sreg <= fifo_rd_data_i;
      state        <= TX_START; 
    end
//-------------------------------------------------------------------------------------------------    
    TX_START: 
    begin 
      if (tick_i)                                                     
      begin
      ticks_cnt      <= ticks_cnt + 1;
        if (ticks_cnt == OVERSAMPLE_RATE - 1 )     
        begin
          tx_o        <= tx_byte[0];
          state       <= TX_DATA;
        end               
      end
    end
//-------------------------------------------------------------------------------------------------       
     TX_DATA: 
     begin
       if (tick_i)                                                     
       begin
       ticks_cnt      <= ticks_cnt + 1;
         if (ticks_cnt == OVERSAMPLE_RATE - 1 )     
         begin
           tx_o        <= tx_byte[1];
           tx_byte     <= tx_byte >> 1;
           idx         <= idx + 1;
           if (idx == NUM_BITS - 1) 
           begin
           idx        <= '0;
             if (PARITY_ON) 
             begin
               state       <= TX_PARITY;
               if (PARITY_EO==EVEN_PAR)
                 tx_o      <= ^tx_byte_sreg;
               else if (PARITY_EO==ODD_PAR)
                 tx_o      <= ~^tx_byte_sreg;
             end 
             else 
             begin
               state       <= TX_STOP;
               tx_o        <= 1'b1;
             end
           end
         end 
       end
     end  
//-------------------------------------------------------------------------------------------------        
    TX_PARITY: 
    begin      
      if (tick_i)                                                     
      begin
      ticks_cnt      <= ticks_cnt + 1;
        if (ticks_cnt == OVERSAMPLE_RATE - 1 )
        begin
          tx_o        <= 1'b1;
          state       <= TX_STOP;
        end 
      end
    end
//-------------------------------------------------------------------------------------------------          
    TX_STOP:
    begin        
      if (tick_i)                                                     
      begin
      ticks_cnt      <= ticks_cnt + 1;
        if (ticks_cnt == OVERSAMPLE_RATE - 1 )
        begin
          stop_b_cnt  <= stop_b_cnt + 1; 
          if (stop_b_cnt == NUM_STOP_BITS ) 
          begin
            stop_b_cnt <= '0;
            tx_o       <= 1'b1;
            state      <= TX_IDLE;
          end
        end  
      end    
    end  
//-------------------------------------------------------------------------------------------------         
    default: 
    begin      
      tx_byte           <= '0;
      tx_byte_sreg      <= '0;
      idx               <= '0;
      tx_o              <= 1'b1;
      stop_b_cnt        <= 1'b0;
      state             <= TX_IDLE;       
    end      
  endcase
end
    
endmodule