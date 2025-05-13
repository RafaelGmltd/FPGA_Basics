module testbench;
logic        CIN;
logic [3:0]  A, B;
logic [3:0]  SUM;
logic        COUT;

// Instantiating the device under test (DUT)
add_4 
uut 
(
.CIN  (CIN),
.A    (A),
.B    (B),
.SUM  (SUM),
.COUT (COUT)
);

// Declaring the loop variable
    integer i;

initial 
begin
 // Initializing inputs
CIN = 0;
A   = 4'b0000;
B   = 4'b0000;   
// Looping through all combinations of A and B from 0000 to 1111
for (i = 0; i < 16; i = i + 1) 
begin
A = i;            // Update A with the current value of i
B = i;            // Update B with the current value of i
#10;              // Wait for 10 time units (simulation delay)
end 
// End the simulation after the loop
$finish;
end

endmodule


