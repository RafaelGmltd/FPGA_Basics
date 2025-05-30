
`default_nettype none
import pkg_msg::*;

module uart_rx_msg
(
  input wire          clk_i,
  input wire          rst_i,
  
//from uart_rx
  input wire [7 :0]   rxd_byte_i,
  input wire          rxd_err_i,
  input wire          rxd_vld_i,

// to uart_tx_msg
  output logic [7 :0] cmd_reg_o,
  output logic        cmd_reg_vld_o,
  output logic        rxd_msg_err_o, 

// to cordic
  output logic        cordic_start_o,
  output logic [47:0] cordic_theta_o,
  output logic        cordic_pipe_en_o,

// debug
  output wire         state_lfsr_debug,
  output wire [2 :0]  state_cmd_debug, 
  output wire [7 :0]  LFSR_REG,
  output wire         byte_done

 );
 
logic        lfsr_cnt_en,
             lfsr_load;
logic [7 :0] lfsr_seed,
             lfsr_reg;
lfsr
#(
  .N    (8   ),
  .POLY (POLY)
)
i_lfsr
(
  .clk_i    (clk_i       ),
  .rst_i    (rst_i       ),
  .cnt_en_i (lfsr_cnt_en ),
  .load_i   (lfsr_load   ),
  .seed_i   (lfsr_seed   ),
  .lfsr_o   (lfsr_reg    )
);

// LFSR control FSM
typedef enum logic 
{
    LFSR_STATE_LOAD, 
    LFSR_STATE_COUNT
} 
lfsr_state_t;

lfsr_state_t 
lfsr_state;

logic [3:0] count2eight;
logic crc_byte_done;

always_ff @(posedge clk_i)
  if (rst_i) 
  begin
    count2eight         <= '0;
    crc_byte_done       <= 1'b0;
    lfsr_load           <= 1'b0;
    lfsr_cnt_en         <= 1'b0;
    lfsr_seed           <= '0;
    lfsr_state          <= LFSR_STATE_LOAD;
  end
   
  else 
  begin    
    crc_byte_done     <= 1'b0;
    lfsr_load         <= 1'b0;
    lfsr_cnt_en       <= 1'b0;
    
    case (lfsr_state) 
      LFSR_STATE_LOAD: 
      begin
        if (rxd_vld_i) 
        begin
          lfsr_load   <= 1'b1;
          lfsr_seed   <= lfsr_reg ^ rxd_byte_i;
          lfsr_state  <= LFSR_STATE_COUNT;
        end
      end
      
      LFSR_STATE_COUNT: 
      begin
        lfsr_cnt_en   <= 1'b1;
        count2eight   <= count2eight + 1;
        if (count2eight == 7) 
        begin
          count2eight     <= '0;
          crc_byte_done   <= 1'b1;
          lfsr_state      <= LFSR_STATE_LOAD;
        end
      end
      
      default: 
      begin
        crc_byte_done     <= 1'b0;
        count2eight       <= '0;
        lfsr_load         <= 1'b0;
        lfsr_cnt_en       <= 1'b0;
        lfsr_seed         <= '0;
        lfsr_state        <= LFSR_STATE_LOAD;
      end
          
    endcase
    
    if (rxd_err_i || rxd_msg_err_o) 
    begin
      crc_byte_done     <= 1'b0;
      count2eight       <= '0;
      lfsr_load         <= 1'b0;
      lfsr_cnt_en       <= 1'b0;
      lfsr_seed         <= '0;
      lfsr_state        <= LFSR_STATE_LOAD;
    end
  end

// CMD sequence FSM
typedef enum logic[2 :0]
{
    STATE_HEADER,
    STATE_CMD,
    STATE_SINGLE_TRANS,
    STATE_DISABLE,
    STATE_ENABLE,
    STATE_CRC_CHECK,
    STATE_CRC_CHECK_II
} 
cmd_seq_state_t;
  
cmd_seq_state_t 
cmd_seq_state;
  
// RX msg registers
logic [2:0] count2six;   //считаем количество байт которые для угла их 6 штук и эти байты в o_cordic_theta будут сохраняться

always_ff @(posedge clk_i)
if (rst_i)
begin
    cmd_seq_state       <= STATE_HEADER;
    count2six           <= '0;
    // to tx msg
    cmd_reg_o           <= '0;
    cmd_reg_vld_o       <= 1'b0;
    rxd_msg_err_o       <= 1'b0;
        
    // to cordic
    cordic_start_o      <= 1'b0;
    cordic_theta_o      <= '0;
    cordic_pipe_en_o    <= 1'b1;
end

else 
begin  
     // to tx_msg
    cmd_reg_o           <= '0;
    cmd_reg_vld_o       <= 1'b0;
    rxd_msg_err_o       <= 1'b0;
      
    // to cordic
    cordic_start_o      <= 1'b0;
    cordic_theta_o      <= cordic_theta_o;
    cordic_pipe_en_o    <= cordic_pipe_en_o;
      
    case (cmd_seq_state)
    STATE_HEADER: 
    begin
        cmd_seq_state <= STATE_HEADER;
        count2six     <= '0;
        if (rxd_vld_i && (rxd_byte_i == BYTE_HEADER)) // приняли хэдр
            cmd_seq_state   <= STATE_CMD;
    end
        
    STATE_CMD: 
    begin
        if (rxd_vld_i) // приняли второй байт это операция
        begin  
            case (rxd_byte_i)
              CMD_SINGLE_TRANS: cmd_seq_state   <= STATE_SINGLE_TRANS;
              CMD_DISABLE:      cmd_seq_state   <= STATE_DISABLE;
              CMD_ENABLE:       cmd_seq_state   <= STATE_ENABLE;
              default:          cmd_seq_state   <= STATE_HEADER;
            endcase
            cmd_reg_o       <= rxd_byte_i; // сохранили команду и ее в tx msg
            cmd_reg_vld_o   <= 1'b1;       // валидное 
          end
    end
        
    STATE_SINGLE_TRANS: 
    begin
        if (rxd_vld_i) // пошли байты с угла
        begin
            cordic_theta_o  <= {rxd_byte_i, cordic_theta_o[47:8]};
            count2six       <= count2six + 1;
            if (count2six == 5) // все 6 пришли 
            begin
              count2six         <= '0;
              cordic_start_o    <= 1'b1; // запустили кордик
              cmd_seq_state     <= STATE_CRC_CHECK; // перешли на проверку
            end
        end
    end
  
    STATE_DISABLE: 
    begin
        cordic_pipe_en_o  <= 1'b0;
        cmd_seq_state         <= STATE_CRC_CHECK;
    end
        
    STATE_ENABLE: 
    begin
        cordic_pipe_en_o  <= 1'b1;
        cmd_seq_state         <= STATE_CRC_CHECK;
    end
        
    STATE_CRC_CHECK: 
    begin
        if (crc_byte_done) 
        begin
            cmd_seq_state   <= STATE_CRC_CHECK_II;
        end
    end

    STATE_CRC_CHECK_II: 
    begin
        if (crc_byte_done) 
        begin
            cmd_seq_state   <= STATE_HEADER;
            rxd_msg_err_o   <= (lfsr_reg != 0);
        end
    end
        
    default: 
    begin
        cmd_seq_state       <= STATE_HEADER;
        count2six           <= '0;
        cmd_reg_o           <= '0;
        cmd_reg_vld_o       <= 1'b0;
        rxd_msg_err_o       <= 1'b0;
        cordic_start_o      <= 1'b0;
        cordic_theta_o      <= '0;
        cordic_pipe_en_o    <= 1'b1;
    end
          
    endcase
      
    if (rxd_err_i || rxd_msg_err_o) // если ошибка есть то все сбрасываем
    begin
        cmd_seq_state       <= STATE_HEADER;
        count2six           <= '0;
 
        // to tx msg
        cmd_reg_o           <= '0;
        cmd_reg_vld_o       <= 1'b0;
        rxd_msg_err_o       <= 1'b0;
        
        // to cordic
        cordic_start_o      <= 1'b0;
        cordic_theta_o      <= '0;
        cordic_pipe_en_o    <= 1'b1;
    end      
end

assign state_lfsr_debug = lfsr_state;
assign state_cmd_debug  = cmd_seq_state;
assign LFSR_REG         = lfsr_reg;
assign byte_done        = crc_byte_done;
endmodule
