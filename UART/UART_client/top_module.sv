`default_nettype none
module top_module
#(
  parameter OVERSAMPLE_RATE = 16,  
  parameter FREQ            = 100_000_000,
  parameter BAUDRATE        = 921_600,
  parameter NUM_BITS        = 11,           // 1 start bit, 8 databit, 1 parity bit, 1 stop bit
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

// Reset synchronizer for system стабилизируем сигнал rst если он от кнопки идет ввыравниваем его по такту
// в течении двух тактов придет
logic [1 :0] sync_reg;
logic        sync_rst;

always_ff @(posedge clk_i or negedge rst_i)
if (rst_i) 
  sync_reg <= 2'b00;
else          
  sync_reg <= {sync_reg[0], 1'b1};

assign sync_rst = sync_reg[1]; // на второй такт придет
    
logic tick;

logic [7 :0]       rxd_byte;
logic              rxd_vld, 
                   rxd_err;
assign rxd_err_o = rxd_err; 

    
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
    
uart_rx
#(
  .OVERSAMPLE_RATE (OVERSAMPLE_RATE),
  .NUM_BITS        (NUM_BITS       ),
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
  .clk_i           (clk_i         ),
  .rst_i           (rst_i         ),    
// in from uart_rx
  .rxd_byte_i      (rxd_byte      ),
  .rxd_vld_i       (rxd_vld       ),
  .rxd_err_i       (rxd_err       ),   
// out to uart_tx_msg
  .cmd_reg_o       (cmd_reg       ),
  .cmd_reg_vld_o   (cmd_reg_vld   ),
  .rxd_msg_err     (rxd_msg_err   ),
// out to cordic
  .cordic_start_o   (cordic_start  ),
  .cordic_theta_o   (cordic_theta  ),
  .cordic_pipe_en_o (cordic_pipe_en)
);

logic         cordic_done;
logic [47 :0] cordic_sin_theta, 
              cordic_cos_theta;

// CORDIC
cordic_sincos 
#(
  .STAGES     (48),
  .BITS       (48)
) 
i_cordic_sincos 
(
  .clk_i.          (clk_i              ),
  .rst_i           (rst_i              ),
  .pipeline_en_i   (cordic_pipeline_en ),
  .start_i         (cordic_start       ),
  .theta_i         (cordic_theta       ),            
  .done_o          (cordic_done        ),
  .sin_theta_o     (cordic_sin_theta   ),  
  .cos_theta_o     (cordic_cos_theta   )   
); 

logic [7 :0]  txd_byte;
logic         txd_byte_valid;

// TX MSG
uart_tx_msg 
i_uart_tx_msg 
(
  .clk_i           (clk_i            ),
  .rst_i           (rst_i            ),    
// from uart rx msg
  .cmd_reg_i          (cmd_reg          ),
  .cmd_vld_i          (cmd_reg_vld      ),
  .rxd_msg_err_i      (rxd_msg_err      ),    
// from cordic
  .cordic_sin_theta_i (cordic_sin_theta ),
  .cordic_cos_theta_i (cordic_cos_theta ),
  .cordic_done_i      (cordic_done      ),   
// to uart tx
  .txd_byte_o         (txd_byte         ),
  .txd_byte_valid_o   (txd_byte_valid   )
);

logic        fifo_wr_en, 
             fifo_rd_en, 
             fifo_full, 
             fifo_empty;
logic [7 :0] fifo_wr_data, 
             fifo_rd_data;

assign fifo_wr_en   = ( (txd_byte_valid) && (!fifo_full) );
assign fifo_wr_data = txd_byte;

// FIFO between TX MSG and TX
sync_fifo 
#(
  .WIDTH  (8),
  .DEPTH  (64)
) 
i_sync_fifo
(
  .clk_i           (clk_i        ),
  .rst_i           (rst_i        ),
  .wr_en_i         (fifo_wr_en   ),
  .rd_en_i         (fifo_rd_en   ),
  .wr_data_i       (fifo_wr_data ),
  .rd_data_o       (fifo_rd_data ),
  .full_o          (fifo_full    ),
  .empty_o         (fifo_empty   )
);

// UART TX
uart_tx 
#(
  .OVERSAMPLE_RATE (OVERSAMPLE_RATE),
  .NUM_BITS        (NUM_BITS       ),
  .PARITY_ON       (PARITY_ON      ),
  .PARITY_EO       (PARITY_EO      )
) 
i_uart_tx
(
  .clk_i,
  .rst_i           (rst_i        ),
  .tick_i          (tick         ),
  .fifo_empty_i    (fifo_empty   ),
  .fifo_rd_data_i  (fifo_rd_data ),
  .fifo_rd_en_o    (fifo_rd_en   ),
  .tx_o            (tx_o         )
  );

endmodule