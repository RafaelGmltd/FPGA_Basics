module uart_rx #(
  parameter CLK_FREQ_MHZ    = 100_000_000,
  parameter BAUD_RATE       =   3_000_000, // 921600 пока на него в расчетах ориентироваться будем 
  parameter OVERSAMPLE_RATE =          16, // Common choices: 8 or 16
  parameter NUM_DATA_BITS   =           8, // Within 5-9
  parameter PARITY_ON       =           1, // 0: Parity disabled. 1: Parity enabled.
  parameter PARITY_EO       =           1  // 0: Even parity. 1: Odd parity.
)
(
  input wire                      i_clk,
  input wire                      i_rst_n,
  input wire                      i_rx,            // принимаем по одному биту
  output reg  [NUM_DATA_BITS-1:0] o_rx_byte,       // это на выход вектор из дата битов
  output reg                      o_rx_byte_valid, // данные готовы все приняли
  output reg                      o_rx_err         //  проверка четность не четность если ошибка 
);
  
// Parity even/odd encoding
localparam EVEN_PAR = 0; // четное
localparam ODD_PAR  = 1; // нечетное 


  // Это выборка из трек последовательных битов по последнему значению пришедшему [2] делаем вывод 0 или 1 
  //- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - 
  // Synchronize rx line into FPGA clock domain
logic [2:0] rx_sync;
logic rx;
  
assign rx = rx_sync[2];
  
always @(posedge i_clk) 
begin
  if (!i_rst_n) rx_sync <= 3'b000;
  else          rx_sync <= {rx_sync[1:0], i_rx};
end
//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  -


// Это генератор тиков он его прямо внутри модуля влупил если значение baud == 921600 значит тик у нас будет хай каждый
// OVERSAMP_PULSEGEN_MAX == 6.7616847777... он его в инт округляет до 7 то есть каждый 7 систем клок один тик
//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  -
// Oversample pulse generation
localparam OVERSAMP_PULSEGEN_MAX = int'(real'(CLK_FREQ_MHZ) / (real'(BAUD_RATE)*real'(OVERSAMPLE_RATE))); // OVERSAMP_PULSEGEN_MAX == 6.7616847777... round-> 7
                                                                                                          // OVERSAMP_PULSEGEN_MAX == 6.7616847777... 
                                                                                                          // он его в инт округляет до 7 то есть каждый 7 систем клок один тик
logic [$clog2(OVERSAMP_PULSEGEN_MAX)-1:0] oversamp_pulsegen;                                              // oversamp_pulsegen [2 :0] счетчик когда 7 доходит пуляем тик хай
  
  // Oversample counter
localparam OVERSAMP_CNT_MAX = OVERSAMPLE_RATE;                                                            // OVERSAMP_CNT_MAX == 16 это максимальное значение счетчика тиков
                                                                                                          // если 16 то читаем бит (на 1 бит 16 тиков)
logic [$clog2(OVERSAMP_CNT_MAX)-1:0] oversamp_cnt;                                                        // oversamp_cnt == [3 :0] это просто счетчик тиков до 16 дойдет бит считем 
  
  // Byte index register
logic [$clog2(NUM_DATA_BITS)-1:0] idx;                                                                    // это счетчик считанных битов сколько битов записали
//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  -


// Это FSM начальное состояние -> обрабатываем дата биты -> проверка четности не четности -> стоп бит
//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  -

  // Control FSM
typedef enum {
  RX_START, 
  RX_DATA, 
  RX_PARITY,
  RX_STOP
  }state_t;
  state_t state;
  
always_ff @(posedge i_clk)
begin
  if (!i_rst_n) 
  begin
    oversamp_pulsegen <= '0;
    oversamp_cnt      <= '0;
    idx               <= '0;
    o_rx_byte         <= '0;
    o_rx_err          <= 1'b0;
    o_rx_byte_valid   <= 1'b0;
    state             <= RX_START;
  end 
  else 
  begin
    case (state)

      RX_START: begin
        o_rx_err          <= 1'b0;
        o_rx_byte_valid   <= 1'b0;
          if (!rx) 
          begin                                                        // первый бит входной  0 то есть старт бит 
            oversamp_pulsegen   <= oversamp_pulsegen + 1;              // начинаем увеличивать счетчки когда будет 7 значит тик 
            if (oversamp_pulsegen == OVERSAMP_PULSEGEN_MAX - 1)        // 7 -> тик
            begin                                              
              oversamp_pulsegen <= '0;                                 // обнуляем счеичик который до тик считает
              oversamp_cnt      <= oversamp_cnt + 1;                   // счетчик тиков помним что один бит занимет 16 тиков
                                                                       // но тут логика немного другая на половине бита идем на обработку
                                                                       // это как в книге первый старт бит до середины доходим 
              if (oversamp_cnt == OVERSAMP_CNT_MAX/2 - 1)              // тут когда счетчик доходит до половины бита то есть 7 
              begin                                                     
                oversamp_cnt    <= '0;                                 // обнуляем счетчик тиков 
                state           <= RX_DATA;                            // перешли на след состояние на обработку бита 
              end
            end
          end 
          else 
          begin
            oversamp_pulsegen   <= '0;                                // если первый бит не 0 то ничего не делаем все счетчики в нулях
            oversamp_cnt        <= '0;
          end             
        end
        
        RX_DATA: begin                                                // пошли на обработку битов
          o_rx_err          <= 1'b0;                            
          o_rx_byte_valid   <= 1'b0;
          oversamp_pulsegen     <= oversamp_pulsegen + 1;                  // опять начинаем считать когда тик произойдет то есть на 7 клоке тик
          if (oversamp_pulsegen == OVERSAMP_PULSEGEN_MAX - 1)              // 7 клок тик
          begin
              oversamp_pulsegen <= '0;                                     // обнулили этот счетчик
              oversamp_cnt      <= oversamp_cnt + 1;                       // начали считать тики 
              if (oversamp_cnt == OVERSAMP_CNT_MAX - 1)                   // тут уже до 16 считаем это информациионный бит мы счейчас в середине 
              begin
                                                                           // информационного бита это как по книге  
                oversamp_cnt        <= '0;                                 // скидываем счетчик тиков
                idx                 <= idx + 1;                            // счетчик битов обработанных первый бит сюдаааа
                o_rx_byte           <= {rx, o_rx_byte[NUM_DATA_BITS-1:1]}; // тут через сдвиг этот дата сохраняемм в спец регистр 
                                                                           // куда хранить все биты полученные будем
                if (idx == NUM_DATA_BITS - 1)                              // так тут если все биты обработали загнали их вв регистр
                                                                           // то есть счетчик битов 7 -> все биты в регистре  
                  if (PARITY_ON)                                           // тут пока не понятно если не ошибаюсь то переходим 
                                                                           // в ссотояние проверки четности не четности то есть в этом состоянии
                                                                           // бит четности приходит и мы с ним будем сравнивать четное не четное кол-во битов 
                                                                           // и на основе этого вывод делаем ровно все пришло или нет                      
                    state           <= RX_PARITY;
                  else
                    state           <= RX_START;
              end
          end
          
        end
        
        RX_PARITY: begin
          o_rx_err          <= 1'b0;
          o_rx_byte_valid   <= 1'b0;
          oversamp_pulsegen     <= oversamp_pulsegen + 1;                             // тик считаем когда придет
          if (oversamp_pulsegen == OVERSAMP_PULSEGEN_MAX - 1)                         // тик пришел
          begin 
              oversamp_pulsegen <= '0;                                                // сбросились
              oversamp_cnt      <= oversamp_cnt + 1;                                  // считаем сколько тиков пришло 
              if (oversamp_cnt == OVERSAMP_CNT_MAX - 1)                               // 16 тиков мы на серидини бита четности надо сравнивать
              begin 
                oversamp_cnt    <= '0;
                state           <= RX_STOP;                                           // и на след клоке на стоп состояние переходим
                // так тут ошибка формируеться в каком случае
                o_rx_err        <= ( (PARITY_EO==EVEN_PAR &&  ((^o_rx_byte) ^ rx)) || (PARITY_EO==ODD_PAR  && ~((^o_rx_byte) ^ rx)) );
                // ну и соответсвенно сигнал о валидных данных если все ок
                o_rx_byte_valid <= ( (PARITY_EO==EVEN_PAR && ~((^o_rx_byte) ^ rx)) || (PARITY_EO==ODD_PAR  &&  ((^o_rx_byte) ^ rx)) );
              end
          end
          
        end
        
        RX_STOP: begin
          o_rx_err          <= 1'b0;
          o_rx_byte_valid   <= 1'b0;
          oversamp_pulsegen     <= oversamp_pulsegen + 1;           // опять ждем тик
          if (oversamp_pulsegen == OVERSAMP_PULSEGEN_MAX - 1)       // тик пришел
          begin
              oversamp_pulsegen <= '0;                              // сбросили
              oversamp_cnt      <= oversamp_cnt + 1;                // считаем тики
              if (oversamp_cnt == OVERSAMP_CNT_MAX - 1 && rx)       // тут если 16 тиков прошло и входной бит 1 это стоп бит он 1 должен быть
              begin
                oversamp_cnt    <= '0;                              // сбросили
                state           <= RX_START;                        // начали все заново
              end
          end
        
        end

        default: begin
          oversamp_pulsegen <= '0;
          oversamp_cnt      <= '0;
          idx               <= '0;
          o_rx_byte         <= '0;
          o_rx_err          <= 1'b0;
          o_rx_byte_valid   <= 1'b0;
          state             <= RX_START;
        end 
      endcase
    end
end
//- - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  - - -  - - - -  - - - - - -  - - - - - -  - - - - - - - - - -  - - - - - -  - - - - - -  -

endmodule