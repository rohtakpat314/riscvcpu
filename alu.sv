// incomplete



module alu(a, b, ALU_control, result, zero, overflow, lt, cout);

parameter data_width = 32; 

input [data_width-1:0] a, b; 
output reg [data_width-1:0] result; 
input [3:0] ALU_control;
output zero, overflow, lt, cout; // either 1 or 0 (true or false) for each 
reg carry; 

/* 

store localparam here 

*/ 


always @(*) begin
    result = 0;
    carry = 0;
    case(ALU_control) 
        ADD: result = a + b;
        SUB: result = a - b;
        OR: result = a | b;
        AND: result = a & b; 
        XOR: result = a ^ b;
        SLL: result = a << b[4:0]; // << point to the left indicate SL 
        SRL: result = a >> b[4:0];
        
        SLT: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // returns true or false 
        default: result = 32'b0;
    endcase
end

assign zero = (result == 0); 
assign lt = ($signed(a) < $signed(b));
assign cout = carry; 


/* explaining my overflow logic 
 * 
 * take a[31] and b[31], which are the MSB of a and b and responsible for 
 * determining the sign of a and b. 
 * if a[31] == 0, then a is positive, else it's negative
 * if b[31] == 0, then b is positive, else it's negative
 * if a[31] == b[31], then that means that both a and b have the same sign
 * overflow occurs when adding/subtracting two numbers but being unable to 
 * express the correct result appropriately in the bitwidth provided, which
 * can occur here when adding two positive numbers and getting a negative value
 * fix: check if the MSB of the result is equal to the MSB of one of the data inputs
 * why?
 * case 1: add two positive numbers, get negative --> overflow 
 * case 2: add two negative numbers, get positive --> overflow 
 */ 

assign overflow = (ALU_control == ADD || ALU_control == SUB) &&
    (a[31] == b[31]) &&
    (result[31] != a[31]);

endmodule 
