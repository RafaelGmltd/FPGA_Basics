`default_nettype none

import pkg_msg::*;

module uart_tx_msg (
input wire      clk_i,
input wire      rst_i,
    
// from uart_rx_msg
input wire [7:0]    cmd_reg_i,
input wire          cmd_vld_i,
input wire          rxd_msg_err_i,
    
// from cordic
input wire [47:0]   cordic_sin_theta_i,
input wire [47:0]   cordic_cos_theta_i,
input wire          cordic_done_i,
    
// to uart tx
output reg [7:0]    txd_byte_o,
output reg          txd_byte_vld_o

);
  
// LFSR to calculate CRC8
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
typedef enum logic [1 :0] 
{
    LFSR_STATE_LOAD, 
    LFSR_STATE_COUNT,
    LFSR_DONE
}
lfsr_state_t;
lfsr_state_t 
lfsr_state;

logic [3 :0] count2eight;
logic        crc_byte_done;
    
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
// кароче тут наобарот формируеться новый пакет и тут CRC новое будет высчитываться на базе sin cos с cordic  ждем txd_byte_vld_o
// он формируеться ниже на 209 смотри только когда кордик закончит вычисления  и тут смотри черезlfsr пропускаем сперва HEADER tx_byte_o
// и сразу же tx_byte_o это напрямую выход отсюда в FIFO идет вот HEADER первый идет затем смотри идет CMD и 12 байт sin cos и самый последний lfsr_reg это CRC на основе всех 14 байт    
    case (lfsr_state) 
      LFSR_STATE_LOAD: 
      begin
        if (txd_byte_vld_o) 
        begin   
            lfsr_load   <= 1'b1;
            lfsr_seed   <= lfsr_reg^txd_byte_o; 
            lfsr_state  <= LFSR_STATE_COUNT;
        end
        end

      LFSR_STATE_COUNT: 
      begin
        lfsr_cnt_en <= 1'b1;
        count2eight   <= count2eight + 1;
        if (count2eight == 7) 
        begin
            count2eight     <= '0;
            lfsr_state      <= LFSR_DONE;
        end
      end

      LFSR_DONE: 
      begin
        crc_byte_done   <= 1'b1;
        lfsr_state      <= LFSR_STATE_LOAD;
      end
        default: begin
          crc_byte_done     <= 1'b0;
          count2eight       <= '0;
          lfsr_load         <= 1'b0;
          lfsr_cnt_en       <= 1'b0;
          lfsr_seed         <= '0;
          lfsr_state        <= LFSR_STATE_LOAD;
        end

    endcase
      
    if (rxd_msg_err_i) 
    begin
        crc_byte_done     <= 1'b0;
        count2eight       <= '0;
        lfsr_load         <= 1'b0;
        lfsr_cnt_en       <= 1'b0;
        lfsr_seed         <= '0;
        lfsr_state        <= LFSR_STATE_LOAD;
    end
  end
  
// FSM to recognize current operating cmd (length of operands needed for range cmd)
// Once cmd is recognized, accept cordic outputs and transmit byte-wise to uart_tx along w/ crc
typedef enum logic [2 :0]
{
    STATE_IDLE,
    STATE_SINGLE_TRANS,
    STATE_SINGLE_TRANS_II,
    STATE_SINGLE_TRANS_III,
    STATE_TX_CRC8
}
tx_msg_state_t;

tx_msg_state_t tx_msg_state;

logic [7 :0] bytes2send [12]; // массив куда будем собирать с кордика 12 байт син кос
logic [3 :0] byte_cnt;

always_ff @(posedge clk_i)
  if (rst_i) 
  begin
    tx_msg_state      <= STATE_IDLE;
    bytes2send        <= '{default:'0};
    byte_cnt          <= '0;
    txd_byte_vld_o    <= 1'b0;
    txd_byte_o        <= '0;
  end 
  else 
  begin    
    txd_byte_vld_o   <= 1'b0;

    case (tx_msg_state)
//-------------------------------------------------------------------------------------------------
      STATE_IDLE:
      begin
        if (cmd_vld_i) // это что что rx msg пришло cmd 
        begin
          case (cmd_reg_i) 
                CMD_SINGLE_TRANS:   tx_msg_state  <= STATE_SINGLE_TRANS;
                default:            tx_msg_state  <= STATE_IDLE;
          endcase
        end
      end
//-------------------------------------------------------------------------------------------------
      STATE_SINGLE_TRANS: 
      begin
      byte_cnt            <= 12;                                               // это считать сколько байт с кордика приняли 12 байт должно быть 6 син 6 кос
        if (cordic_done_i) 
        begin                                                                 // фор можно внутри always блока если нет инстансев
            for (int i = 0; i < 6; i++)                                       //6 итераций косинус из кордик в первые 6 ячеек масива синус во вторые 
            begin
                bytes2send[i]       <= cordic_cos_theta_i[(8*i)+7 -: 8];      // [N -: M]  взять M битов, начиная с бита N, в сторону младших разрядов
                bytes2send[i+6]     <= cordic_sin_theta_i[(8*i)+7 -: 8];      // [N : (N - M)+1] -> [15 -: 8] -> [15 :8]
            end
            txd_byte_vld_o       <= 1'b1;                                      // вот сейчас только на аут и в фифо и в lfsr кидает первый байт header
            txd_byte_o           <= BYTE_HEADER;
            tx_msg_state         <= STATE_SINGLE_TRANS_II;
        end
      end
//-------------------------------------------------------------------------------------------------
      STATE_SINGLE_TRANS_II: 
      
      begin
        if (crc_byte_done)     // первый байт через lfsr прогнали
        begin
            txd_byte_vld_o         <= 1'b1;                                     // вот сейсас байт с cmd отправляем в lfsr и в фифо
            txd_byte_o             <= CMD_SINGLE_TRANS;
            tx_msg_state           <= STATE_SINGLE_TRANS_III;
        end
      end
//-------------------------------------------------------------------------------------------------
      STATE_SINGLE_TRANS_III: 
      begin
        if (crc_byte_done) 
        begin
            txd_byte_vld_o     <= 1'b1;                                        // тут с массива начинаем по очереди закидывать в lfsr син кос посчитанные с кордика и в фифо их
            txd_byte_o         <= bytes2send[12 - byte_cnt];                    
            byte_cnt           <= byte_cnt - 1;                              
                if (byte_cnt == 1)                                             // если счетчик 1 то все 12 загрузили обработали
                begin
                    tx_msg_state    <= STATE_TX_CRC8;
                end
        end
      end
//-------------------------------------------------------------------------------------------------
      STATE_TX_CRC8: 
      begin
        if (crc_byte_done) 
        begin
            txd_byte_vld_o    <= 1'b1;              // записали как раз новый посчитанный CRC-8 на основе новых значений его потом питон на свое стороне будет считать и сравнивать
            txd_byte_o        <= lfsr_reg;
            tx_msg_state      <= STATE_IDLE;
        end
      end
//-------------------------------------------------------------------------------------------------
      default: 
      begin
        tx_msg_state      <= STATE_IDLE;
        txd_byte_vld_o    <= 1'b0;
        txd_byte_o        <= '0;
        bytes2send        <= '{default:'0};
        byte_cnt          <= '0;
      end
    endcase
//-------------------------------------------------------------------------------------------------
    if (rxd_msg_err_i) 
    begin
        tx_msg_state      <= STATE_IDLE;
        bytes2send        <= '{default:'0};
        byte_cnt          <= '0;
        txd_byte_vld_o    <= 1'b0;
        txd_byte_o        <= '0;
    end    
  end

endmodule