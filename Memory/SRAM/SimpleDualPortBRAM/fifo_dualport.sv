module fifo_dualport #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             push,
    input  logic             pop,
    input  logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_o,
    output logic             empty,
    output logic             full
);

    // ------------------------------------------------------------------------
    // Local parameters
    // ------------------------------------------------------------------------

    localparam WIDTH_PTR   = $clog2(DEPTH);
    localparam MAX_PTR     = WIDTH_PTR'(DEPTH - 1);

    // ------------------------------------------------------------------------
    // Local signals
    // ------------------------------------------------------------------------

    // SRAM
    logic             ren;
    logic             wen;
    logic [WIDTH-1:0] sram_out;

    // FIFO control
    logic [W_PTR-1:0] wr_ptr;
    logic [W_PTR-1:0] rd_ptr;
    logic             wr_circle_odd;
    logic             rd_circle_odd;

    // Prefetch and bypass
    logic             enable_bypass;
    logic             bypass_valid;
    logic [WIDTH-1:0] bypass_data;
    logic             almost_empty;
    logic [W_PTR-1:0] prefetch_ptr;

    // ------------------------------------------------------------------------
    // MUX
    // ------------------------------------------------------------------------
    assign wen           =  push && ~enable_bypass;
    assign ren           =  pop && ~almost_empty;
    assign prefetch_ptr  = (rd_ptr == MAX_PTR) ? WIDTH_PTR'(0) : WIDTH_PTR'(rd_ptr + 1'b1);
    assign almost_empty  =  wr_ptr == prefetch_ptr;
    assign enable_bypass =  push && (empty_o || (almost_empty && pop));
    assign data_o        =  bypass_valid ? bypass_data : sram_out;

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
        .clk     ( clk          ),
        .wen_i   ( wen          ),
        .ren_i   ( ren          ),
        .waddr_i ( wr_ptr       ),
        .raddr_i ( prefetch_ptr ),
        .data_i  ( data_i       ),
        .data_o  ( sram_out     )
    );

    // ------------------------------------------------------------------------
    // Prefetch and bypass logic
    // ------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            bypass_valid <= 1'b0;
        end else if (enable_bypass) begin
            bypass_valid <= 1'b1;
        end else if (pop) begin
             <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (enable_bypass) begin
            bypass_data <= data_i;
        end
    end

    // ------------------------------------------------------------------------
    // Main FIFO logic
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
        else if (push) 
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
        else if (pop) 
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