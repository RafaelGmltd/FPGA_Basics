module uart_tx #(
  parameter CLK_FREQ_MHZ    = 100_000_000,
  parameter BAUD_RATE       =   3_000_000, // 921600 пока на него в расчетах ориентироваться будем 
  parameter NUM_DATA_BITS   =           8, // Within 5-9
  parameter PARITY_ON       =           1, // 0: Parity disabled. 1: Parity enabled.
  parameter PARITY_EO       =           1, // 0: Even parity. 1: Odd parity.
  parameter NUM_STOP_BITS   =           1  // Within 1-2
)
(
// Тут я так понимаю на отправитель данные с фифошки будут идти 
input  wire                       i_clk,
input  wire                       i_rst_n,
input  wire                       i_fifo_empty,   // это входящий сигнал от фифо если пустая то не готова передавать данные TX
input  wire  [NUM_DATA_BITS-1 :0] i_fifo_rd_data, // это данные с фифошки
output wire                       o_fifo_rd_en,   // готов новые данные от фифо получать я свободен все ресиверу передал
output reg                        o_tx            // по одному биту передаю данные ресиверу
  );

// Parity even/odd encoding
localparam EVEN_PAR = 0;
localparam ODD_PAR  = 1;
//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - 


//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - 
// Тут логика формирования тика немного другая тут он вообще просто сразу 16 тиков считает из расчета что на один тик идет 7 клоков

  // Baudperiod counter
localparam BAUDPER_CNT_MAX = int'(real'(CLK_FREQ_MHZ) / real'(BAUD_RATE)); // тут 109 будет то есть каждый бит в течении 109 клоков держиться
logic [$clog2(BAUDPER_CNT_MAX)-1:0] baudper_cnt;                           // счетчик завел на период бауда 109 клоков 7 бит надо [6 :0]
  
  // TX byte register
logic [NUM_DATA_BITS-1:0] tx_byte, tx_byte_sreg;                           // два регистра на вектор дата битов
  
  // Byte index register
logic [$clog2(NUM_DATA_BITS)-1:0] idx;                                     // счетчик дата битов
  
  // Stop bit counter
logic stop_b_cnt;                                                          // пока хз
//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - 

//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - 

  // Control FSM
typedef enum {
  TX_IDLE, 
  TX_GET_DATA,
  TX_START, 
  TX_DATA, 
  TX_PARITY, 
  TX_STOP

  } state_t;
state_t state;
  
assign o_fifo_rd_en = (!i_fifo_empty) && state==TX_IDLE;  // я готов принимать данные если фифо не пустой он может мне данные дать и если я в состоянии IDLE
  
always_ff @(posedge i_clk)
begin
  if (!i_rst_n) 
  begin
    tx_byte           <= '0;
    tx_byte_sreg      <= '0;
    baudper_cnt       <= '0;
    idx               <= '0;
    o_tx              <= 1'b1;
    stop_b_cnt        <= 1'b0;
    state             <= TX_IDLE;
  end 
  else 
  begin
      case (state)

        TX_IDLE: begin
          if (!i_fifo_empty) 
          begin
            state           <= TX_GET_DATA;
          end
        end
        
        TX_GET_DATA: begin
        
            o_tx        <= 1'b0;
            tx_byte     <= i_fifo_rd_data;
            tx_byte_sreg<= i_fifo_rd_data;
            state       <= TX_START;
        
        end
        
        TX_START: begin
          
          baudper_cnt   <= baudper_cnt + 1;
          if (baudper_cnt == BAUDPER_CNT_MAX - 1) begin
            baudper_cnt <= '0;
            o_tx        <= tx_byte[0];
            state       <= TX_DATA;
          end
                   
        end
        
        TX_DATA: begin
          
          baudper_cnt   <= baudper_cnt + 1;
          if (baudper_cnt == BAUDPER_CNT_MAX - 1) begin
            baudper_cnt <= '0;
            o_tx        <= tx_byte[1];
            tx_byte     <= tx_byte >> 1;
            idx         <= idx + 1;
            if (idx == NUM_DATA_BITS - 1) begin
              idx       <= '0;
              if (PARITY_ON) begin
                state       <= TX_PARITY;
                if (PARITY_EO==EVEN_PAR)
                  o_tx      <= ^tx_byte_sreg;
                else if (PARITY_EO==ODD_PAR)
                  o_tx      <= ~^tx_byte_sreg;
              end else begin
                state       <= TX_STOP;
                o_tx        <= 1'b1;
              end
            end
          end
          
        end
        
        TX_PARITY: begin
          
          baudper_cnt   <= baudper_cnt + 1;
          if (baudper_cnt == BAUDPER_CNT_MAX - 1) begin
            baudper_cnt <= '0;
            o_tx        <= 1'b1;
            state       <= TX_STOP;
          end
          
        end
        
        TX_STOP: begin
          
          baudper_cnt   <= baudper_cnt + 1;
          if (baudper_cnt == BAUDPER_CNT_MAX - 1) begin
            baudper_cnt <= '0;
            stop_b_cnt  <= ~stop_b_cnt; 
            if (stop_b_cnt == NUM_STOP_BITS - 1) begin
              stop_b_cnt<= '0;
              o_tx      <= 1'b1;
              state     <= TX_IDLE;
            end
          end
          
        end
        
        default: begin
          
          tx_byte           <= '0;
          tx_byte_sreg      <= '0;
          baudper_cnt       <= '0;
          idx               <= '0;
          o_tx              <= 1'b1;
          stop_b_cnt        <= 1'b0;
          state             <= TX_IDLE;
          
        end
          
      endcase
    end
  
  
endmodule