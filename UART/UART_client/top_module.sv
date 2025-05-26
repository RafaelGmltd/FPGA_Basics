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
input                   clk_i,
input                   rst_i,
input  [1 :0]           rate_i,

//RX
input                   rxd_i,
// output [NUM_BITS -4 :0] rxd_byte_o,
// output                  rxd_vld_o,
output                  rxd_err_o, 

//RX_MSG

output wire             rxd_msg_err_o,
output wire             cordic_pipe_en_o

//debuging
output [2 :0]           fsm_state_rx

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
.FREQ     (FREQ    ),
.BAUDRATE (BAUDRATE)
) 
i_tick
(
.rst_i  (sync_rst ),
.clk_i  (clk_i    ),
.rate_i (2'b00    ),
.tick_o (tick     ) 
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
.clk_i          (clk_i          ),
.rst_i          (sync_rst       ),
.tick_i         (tick           ),
.rxd_i          (rxd_i          ),

// out to RX MSG
.rxd_vld_o      (rxd_vld        ),
.rxd_byte_o     (rxd_byte       ),
.rxd_err_o      (rxd_err        ),
// debug
.fsm_state_rx   (fsm_state_rx   )

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
.clk_i            (clk_i         ),
.rst_i            (sync_rst      ),
    
// in from uart_rx
.rxd_byte_i       (rxd_byte      ),
.rxd_vld_i        (rxd_vld       ),
.rxd_err_i        (rxd_err       ),
    
// out to uart_tx_msg
.cmd_reg_o        (cmd_reg       ),
.cmd_reg_vld_o    (cmd_reg_vld   ),
.rxd_msg_err      (rxd_msg_err   ),
    
// out to cordic
.cordic_start_o   (cordic_start  ),
.cordic_theta_o   (cordic_theta  ),
.cordic_pipe_en_o (cordic_pipe_en)

);
       
endmodule