module lab_top
#(
    parameter CLK       = 100,
              KEY       = 2,
              SW        = 16,
              LED       = 16,
              DIGIT     = 4
)
(
input                   clk,                       
input                   rst,

//- - - - - Keys,Switches,LEDs - - - - - - - 

input        [KEY-1:0]   key,
input        [SW- 1:0]   sw,
output logic [LED-1:0]   led,

//- - - - - Seven Seg Display - - - - - - - 

output logic [      7:0] abcdefgh,
output logic [DIGIT-1:0] digit
);

//assign abcdefgh         = '0;
//assign led              = '0;
//assign digit            = '0;

    localparam sw_actual = (sw > 8) ? 8
                                        : sw;

    logic [(2*w_actual)-1:0 ] pow_mul_stage_1;
    logic [(3*sw_actual)-1:0] pow_mul_stage_2;
    logic [(4*sw_actual)-1:0] pow_mul_stage_3;
    logic [(5*sw_actual)-1:0] pow_mul_stage_4;

    logic [(2*sw_actual)-1:0] pow_data_stage_1_ff;
    logic [(3*sw_actual)-1:0] pow_data_stage_2_ff;
    logic [(4*sw_actual)-1:0] pow_data_stage_3_ff;
    logic [(5*sw_actual)-1:0] pow_data_stage_4_ff;

    logic [sw_actual-1:0] input_stage_0_ff;
    logic [sw_actual-1:0] input_stage_1_ff;
    logic [sw_actual-1:0] input_stage_2_ff;
    logic [sw_actual-1:0] input_stage_3_ff;

    logic [(5*sw_actual)-1:0] pow_output;


    // Input data pipeline
    always_ff @ (posedge clk or posedge rst)
        if (rst) begin
            input_stage_0_ff <= '0;
            input_stage_1_ff <= '0;
            input_stage_2_ff <= '0;
            input_stage_3_ff <= '0;
        end
        else begin
            input_stage_0_ff <= sw;
            input_stage_1_ff <= input_stage_0_ff;
            input_stage_2_ff <= input_stage_1_ff;
            input_stage_3_ff <= input_stage_2_ff;
        end

    // Multiply numbers
    assign pow_mul_stage_1 = input_stage_0_ff * input_stage_0_ff;
    assign pow_mul_stage_2 = input_stage_1_ff * pow_data_stage_1_ff;
    assign pow_mul_stage_3 = input_stage_2_ff * pow_data_stage_2_ff;
    assign pow_mul_stage_4 = input_stage_3_ff * pow_data_stage_3_ff;

    always_ff @ (posedge clk or posedge rst)
        if (rst) begin
            pow_data_stage_1_ff <= '0;
            pow_data_stage_2_ff <= '0;
            pow_data_stage_3_ff <= '0;
            pow_data_stage_4_ff <= '0;
        end
        else begin
            pow_data_stage_1_ff <= pow_mul_stage_1;
            pow_data_stage_2_ff <= pow_mul_stage_2;
            pow_data_stage_3_ff <= pow_mul_stage_3;
            pow_data_stage_4_ff <= pow_mul_stage_4;
        end

assign pow_output = pow_data_stage_4_ff;

assign led = LED'(pow_output);

endmodule