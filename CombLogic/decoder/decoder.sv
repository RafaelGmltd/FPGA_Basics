//This example for lab with board

module decoder
#(
    parameter    W_KEY = 2,
                 W_LED = 16 
)
(
    input        [W_KEY -1:0] key,
    output logic [W_LED -1:0] led 
);

    wire [1:0] in = {key[1], key[0]};

// BOOLIAN    
    wire [3:0] dec0;
    assign dec0 [0] = ~ in [1] & ~ in [0];
    assign dec0 [1] = ~ in [1] &   in [0];
    assign dec0 [2] =   in [1] & ~ in [0];
    assign dec0 [3] =   in [1] &   in [0];
    
// CASE 
    logic [3:0] dec1;
always_comb
    case(in)
    2'b00:   dec1 = 4'b0001;
    2'b01:   dec1 = 4'b0010;
    2'b10:   dec1 = 4'b0100;
    default: dec1 = 4'b1000;
    endcase
    
//SHIFT
    wire [3:0] dec2 = 4'b0001 << in;
    
//INDEX
    logic [3:0] dec3;
    
always_comb
begin
    dec3 = '0;
    dec3 [in] = 1'b1;
end


//
assign led  = W_LED'({ dec0, dec1, dec2, dec3 });
    
endmodule