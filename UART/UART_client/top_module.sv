`default_nettype none
module top_module
#(
  parameter OVERSAMPLE_RATE = 16,  
  parameter FREQ            = 100_000_000,
  parameter BAUDRATE        = 921_600,
  parameter PARITY_ON       =  1,
  parameter PARITY_EO       =  1

)
(
input wire         clk_i,
input wire         rst_i,
input wire [1 :0]  rate_i,
//RX
input wire         rxd_i,
output wire        rxd_err_o, 
//RX_MSG
output wire        rxd_msg_err_o,
output wire        cordic_pipe_en_o,
//TX
output wire        tx_o,            
//debuging
output wire [2 :0] fsm_state_rx

);
//-------------------------------------------------------------------------------------------------
                               //Async reset
// Reset synchronizer for system стабилизируем сигнал rst если он от кнопки идет ввыравниваем его по такту
// в течении двух тактов придет
// rst_i — асинхронный сброс по 1 (потому что в @(posedge rst_i)).
// При срабатывании rst_i регистр сбрасывается мгновенно (асинхронно).
// При отпускании rst_i на каждом такте в sync_reg сдвигается 1 в старший бит.
// то есть смысл в том что если мы системный ресет будем использовать в разные модули а у меня их 10 - 11 
// то есть вероятность что этот ресет не везде одновременно отработает так?
// а тут мы что делаем когда системный ресет а системный ресет на кнопку заведен
// срабатывает мы в регистр из двух битт загружаем нули  затем мы кнопку отпустили системный ресет 0 стал 
// теперь выполняеться элсе на первом такте 1 в 0 индекс загружаеться а на втором такте эта 1 из 0 индекса идет 
// в индекс номер 1 а индекс номер один от этого регистра это глобальный ресет для всех модулей так получаеться
// sync_rst_n становится 1 через два такта после сброса.

logic [1 :0] sync_reg;
logic        sync_rst;

always_ff @(posedge clk_i or negedge rst_i)
if (rst_i) 
  sync_reg <= 2'b00;
else          
  sync_reg <= {sync_reg[0], 1'b1};

assign sync_rst = sync_reg[1]; // на второй такт придет
    
//-------------------------------------------------------------------------------------------------
                               //TICK to RX and TX

logic tick;
tick_gen 
#(
  .FREQ            (FREQ    ),
  .BAUDRATE        (BAUDRATE)
) 
i_tick
(
  .rst_i           (sync_rst ),
  .clk_i           (clk_i    ),
  .rate_i          (2'b00    ),
  .tick_o          (tick     ) 
);
//-------------------------------------------------------------------------------------------------
                               //from PYTHON client to RX to RX MSG   
logic [7 :0]       rxd_byte;
logic              rxd_vld,rxd_err;
assign rxd_err_o = rxd_err; 

uart_rx
#(
  .OVERSAMPLE_RATE (OVERSAMPLE_RATE),
  .NUM_BITS        (11             ),
  .PARITY_ON       (PARITY_ON      ),
  .PARITY_EO       (PARITY_EO      )
) 
i_rx
(
  .clk_i           (clk_i          ),
  .rst_i           (sync_rst       ),
  .tick_i          (tick           ),
  .rxd_i           (rxd_i          ),

// out to RX MSG
  .rxd_vld_o       (rxd_vld        ),
  .rxd_byte_o      (rxd_byte       ),
  .rxd_err_o       (rxd_err        ),
// debug
  .fsm_state_rx    (fsm_state_rx   )

);
//-------------------------------------------------------------------------------------------------
                               //RX MSG to CORDIC and TX_MSG 
logic [7:0]  cmd_reg;
logic        cmd_reg_vld;
logic        rxd_msg_err;
logic        cordic_start;
logic [47:0] cordic_theta;
logic        cordic_pipe_en;

assign cordic_pipe_en_o = cordic_pipe_en;
assign rxd_msg_err_o    = rxd_msg_err;

// RX MSG
uart_rx_msg 
i_uart_rx_msg  
(
  .clk_i            (clk_i          ),
  .rst_i            (sync_rst       ),    
// in from uart_rx
  .rxd_byte_i       (rxd_byte       ),
  .rxd_vld_i        (rxd_vld        ),
  .rxd_err_i        (rxd_err        ),   
// out to uart_tx_msg
  .cmd_reg_o        (cmd_reg        ),
  .cmd_reg_vld_o    (cmd_reg_vld    ),
  .rxd_msg_err      (rxd_msg_err    ),
// out to cordic
  .cordic_start_o   (cordic_start   ),
  .cordic_theta_o   (cordic_theta   ),
  .cordic_pipe_en_o (cordic_pipe_en )
);
//-------------------------------------------------------------------------------------------------
                               //CORDIC to TX_MSG
logic         cordic_done;
logic [47 :0] cordic_sin_theta, cordic_cos_theta;

cordic_sincos 
#(
  .STAGES          (48                 ),
  .BITS            (48                 )
) 
i_cordic_sincos 
(
  .clk_i.          (clk_i              ),
  .rst_i           (sync_rst           ),
  .pipeline_en_i   (cordic_pipeline_en ),
  .start_i         (cordic_start       ),
  .theta_i         (cordic_theta       ),            
  .done_o          (cordic_done        ),
  .sin_theta_o     (cordic_sin_theta   ),  
  .cos_theta_o     (cordic_cos_theta   )   
); 
//-------------------------------------------------------------------------------------------------
                               //TX_MSG to FIFO
logic [7 :0]  txd_byte;
logic         txd_byte_valid;

uart_tx_msg 
i_uart_tx_msg 
(
  .clk_i              (clk_i            ),
  .rst_i              (sync_rst          ),    
// from uart rx msg
  .cmd_reg_i          (cmd_reg          ),
  .cmd_vld_i          (cmd_reg_vld      ),
  .rxd_msg_err_i      (rxd_msg_err      ),    
// from cordic
  .cordic_sin_theta_i (cordic_sin_theta ),
  .cordic_cos_theta_i (cordic_cos_theta ),
  .cordic_done_i      (cordic_done      ),   
// to FIFO
  .txd_byte_o         (txd_byte         ),
  .txd_byte_vld_o     (txd_byte_vld     )
);
//-------------------------------------------------------------------------------------------------
                               //FIFO to TX
logic        fifo_wr_en, fifo_rd_en, fifo_full, fifo_empty;
logic [7 :0] fifo_wr_data, fifo_rd_data;

assign fifo_wr_en   = ( (txd_byte_vld) && (!fifo_full) );
assign fifo_wr_data = txd_byte;

sync_fifo 
#(
  .WIDTH           (8            ),
  .DEPTH           (64           )
) 
i_sync_fifo
(
  .clk_i           (clk_i        ),
  .rst_i           (sync_rst     ),
  .wr_en_i         (fifo_wr_en   ),
  .rd_en_i         (fifo_rd_en   ),
  .wr_data_i       (fifo_wr_data ),
  .rd_data_o       (fifo_rd_data ),
  .full_o          (fifo_full    ),
  .empty_o         (fifo_empty   )
);
//-------------------------------------------------------------------------------------------------
                               //TX to PYTHON client
uart_tx 
#(
  .OVERSAMPLE_RATE (OVERSAMPLE_RATE),
  .NUM_BITS        (8              ),
  .PARITY_ON       (PARITY_ON      ),
  .PARITY_EO       (PARITY_EO      )
) 
i_uart_tx
(
  .clk_i           (clk_i          ),
  .rst_i           (sync_rst       ),
  .tick_i          (tick           ),
  .fifo_empty_i    (fifo_empty     ),
  .fifo_rd_data_i  (fifo_rd_data   ),
  .fifo_rd_en_o    (fifo_rd_en     ),
  .txd_o           (txd_o          )
  );

endmodule