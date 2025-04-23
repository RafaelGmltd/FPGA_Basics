module fifo_dualport #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) 
(
    input  logic             clk,
    input  logic             rst,
    input  logic             push,
    input  logic             pop,
    input  logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_out,
    output logic             empty,
    output logic             full,
//    output logic [WIDTH-1:0] data_sram,
    output logic             bypass_valid,
                             enable_bypass,
                             wr_circle_odd,
                             rd_circle_odd,
                             
    output logic [WIDTH-1:0] wr_ptr,
                             rd_ptr,
                             
    output logic             wen,
                             ren,
                             
    output logic [WIDTH-1:0] bypass_data,
    output logic             almost_empty,
    
    output logic [WIDTH-1:0] prefetch_ptr

    
);
logic [WIDTH -1:0] sram_out;

    // ------------------------------------------------------------------------
    // Local parameters
    // ------------------------------------------------------------------------

    localparam W_PTR       = $clog2(DEPTH);
    localparam MAX_PTR     = W_PTR'(DEPTH - 1);

    // ------------------------------------------------------------------------
    // Local signals
    // ------------------------------------------------------------------------



    // ------------------------------------------------------------------------
    // MUX
    // ------------------------------------------------------------------------
    assign wen           =  push && ~enable_bypass;                                          //MUX_5
    assign ren           =  pop  && ~almost_empty;                                           //MUX_4
    assign data_out      =  bypass_valid ? bypass_data : sram_out;                           //MUX_3
    assign enable_bypass =  push && (empty || (almost_empty && pop));                        //MUX_2
    assign almost_empty  =  wr_ptr == prefetch_ptr;                                          //MUX_1
    assign prefetch_ptr  = (rd_ptr == MAX_PTR) ? W_PTR'(0) : W_PTR'(rd_ptr + 1'b1);          //MUX_0

          
    
    // ------------------------------------------------------------------------
    // SRAM
    // ------------------------------------------------------------------------
    sram_dualport 
    #(
        .WIDTH ( WIDTH ),
        .DEPTH ( DEPTH )
    )
    i_mem 
    (
        .clk            ( clk          ),
        .wen            ( wen          ),
        .ren            ( ren          ),
        .wr_addr        ( wr_ptr       ),
        .rd_addr        ( prefetch_ptr ),
        .data_i         ( data_i       ),
        .data_o         ( sram_out     )
//        .data_out_sram  ( data_sram    )
    );

    // ------------------------------------------------------------------------
    //  Bypass logic
    // ------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) 
        begin
            bypass_valid <= 1'b0;
        end 
        else if (enable_bypass) 
        begin
            bypass_valid <= 1'b1;
        end 
        else if (pop) 
        begin
        bypass_valid    <= 1'b0;
        end
    end

    always_ff @(posedge clk) 
    begin
        if (enable_bypass) 
        begin
            bypass_data <= data_i;
        end
    end

    // ------------------------------------------------------------------------
    // FIFO logic
    // ------------------------------------------------------------------------
    assign empty = (wr_ptr == rd_ptr) && (wr_circle_odd == rd_circle_odd);
    assign full  = (wr_ptr == rd_ptr) && (wr_circle_odd != rd_circle_odd);

    always_ff @(posedge clk) 
    begin
        if (rst) 
        begin
            wr_ptr            <= '0;
            wr_circle_odd     <= 1'b0;
        end
        else if (push & !full) 
        begin
            if (wr_ptr == MAX_PTR) 
            begin
                wr_ptr        <= '0;
                wr_circle_odd <= ~wr_circle_odd;
            end 
            else 
            begin
                wr_ptr        <= wr_ptr + 1'b1;
            end
        end
    end

    always_ff @(posedge clk) 
    begin
        if (rst) 
        begin
            rd_ptr            <= '0;
            rd_circle_odd     <= 1'b0;
        end 
        else if (pop & !empty) 
        begin
            if (rd_ptr == MAX_PTR) 
            begin
                rd_ptr        <= '0;
                rd_circle_odd <= ~rd_circle_odd;
            end 
            else 
            begin
                rd_ptr        <= rd_ptr + 1'b1;
            end
        end
    end

endmodule