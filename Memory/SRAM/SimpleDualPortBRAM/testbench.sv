module tb_fifo_dualport;

    localparam WIDTH = 8;
    localparam DEPTH = 8;

    logic clk;
    logic rst;
    logic push;
    logic pop;
    logic [WIDTH-1:0] data_i;
    logic [WIDTH-1:0] data_out;
    logic empty;
    logic full;
//    logic [WIDTH-1:0] data_sram;
    logic bypass_valid;
    logic enable_bypass;
    logic rd_circle_odd;
    logic wr_circle_odd;
    logic [WIDTH-1:0] wr_ptr;
    logic [WIDTH-1:0] rd_ptr;
    logic wen,ren;
    logic [WIDTH-1:0] bypass_data;
    logic almost_empty;
    logic [WIDTH-1:0] prefetch_ptr; 
    


    fifo_dualport 
    #(.WIDTH(WIDTH),
      .DEPTH(DEPTH)) 
    dut
    (.*);
parameter PERIOD = 10; 

    initial
    begin 
        clk <= 0;
    forever
      begin
    #(PERIOD/2)clk <= ~clk;
      end
    end

    initial 
    begin
        rst <= 1;
        #(PERIOD)
        rst  <= 0;
     end
     
       initial
       begin
       
 //             First Transaction
 //_________________WRITE_______________
       for (int i = 0; i < 8; i = i + 1)
       begin
        @(posedge clk);
        push   <= 1;
        pop    <= 0;  
        data_i <= i;
        end
              
//_________________READ_______________
        @(posedge clk);
        pop    <=1;
        push   <=0;
        repeat(8)
        begin
        #(PERIOD);
        end
             
 //             Second Transaction
//_________________WRITE_______________       
       for (int i = 8; i < 16; i = i + 1)
       begin
        @(posedge clk);
        push   <= 1;
        pop    <= 0;  
        data_i <= i;
        end

//_________________READ_______________ 
        @(posedge clk);
        pop    <=1;
        push   <=0;
        repeat(8)
        begin
        #(PERIOD);
        end
       
 //             Third Transaction 
 //_________________WRITE_______________
       for (int i = 0; i < 8; i = i + 1)
       begin
        @(posedge clk);
        push   <= 1;
        pop    <= 0;  
        data_i <= i;
        end
              
//_________________READ_______________
        @(posedge clk);
        pop    <=1;
        push   <=0;
        repeat(8)
        begin
        #(PERIOD);
        end
//____________________________________       
        #(PERIOD)

// etc.....
        $stop();
    end
    
         initial
         begin
         for (int i = 1; i < 50; i = i + 1)
         begin
         @(posedge clk)
         $display("                         "   );
         $display("________CLK: %0d________ ", i);

         #5ns
         $display ("push: %0d",push                   );
         $display ("pop: %0d",pop                     );
         $display ("empty: %0d", empty                );
         $display ("full: %0d", full                  );
         $display ("prefetch_ptr: %0d", prefetch_ptr  );
         $display ("enable_bypass: %0d", enable_bypass);
         $display ("almost_empty: %0d", almost_empty  );
         $display ("wen: %0d", wen                    );
         $display ("ren: %0d", ren                    );
         #5ns        
         $display ("bypass_vld: %0d",bypass_valid     );
         $display ("w_ptr: %0d", wr_ptr               );
         $display ("w_circle: %0d", wr_circle_odd     );
         $display ("r_ptr: %0d", rd_ptr               );
         $display ("r_circle: %0d", rd_circle_odd     );
         $display ("bypass_reg: %0d", bypass_data     );
         end
         end

endmodule