/*
Larger, more complex circuits are built by composing bigger modules out of smaller modules 
and other pieces (such as assign statements and always blocks) connected together. 
This forms a hierarchy, as modules can contain instances of other modules.
The hierarchy of modules is created by instantiating one module inside another, 
as long as all of the modules used belong to the same project (so the compiler knows where to find the module). 
The code for one module is not written inside another module's body (Code for different modules are not nested)
*/

module add_1
(
input        a,
input        b,
input        cin,      
output logic sum,
output logic cout    
);
	
always_comb
begin 
  if(a & b | cin & a | cin & b) 
    cout = 1'b1;
  else 
    begin
    cout = 0'b0;
    sum = a ^ b ^ cin;
    end
end
endmodule

//Other design source
module add_4
(
input              CIN,
input        [3:0] A, B,
output logic [3:0] SUM,
output logic       COUT
);

logic [2:0] CARRY;

/*
Connecting signals to a module's ports by NAME allows wires to remain correctly 
connected even if the port list changes
*/

add_1 sum_0(.cin(CIN),      .a(A[0]), .b(B[0]), .sum(SUM[0]), . cout(CARRY[0]));
add_1 sum_1(.cin(CARRY[0]), .a(A[1]), .b(B[1]), .sum(SUM[1]), . cout(CARRY[1]));
add_1 sum_2(.cin(CARRY[1]), .a(A[2]), .b(B[2]), .sum(SUM[2]), . cout(CARRY[2]));
add_1 sum_3(.cin(CARRY[2]), .a(A[3]), .b(B[3]), .sum(SUM[3]), . cout(COUT));

/*
The syntax to connect wires to ports by POSITION
ports are connected left to right according to the module's declaration
*/

//add_1 sum_0(CIN, A[0], B[0], SUM[0], CARRY[0]);  
//add_1 sum_1(CARRY[0], A[1], B[1], SUM[1], CARRY[1]);
//add_1 sum_2(CARRY[1], A[2], B[2], SUM[2], CARRY[2]);
//add_1 sum_3(CARRY[2], A[3], B[3], SUM[3], COUT);

endmodule
